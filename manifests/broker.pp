# == Class kafka::broker
#
# === Parameters
#
# TODO: Document each class parameter.
#
# [*kafka_gc_log_opts*]
#   Use this parameter for all Java Garbage Collection settings with the exception of configuring `-Xloggc:...`.
#   Use $gc_log_file for the latter.
#
# [*kafka_log4j_opts*]
#   Use this parameter for all logging settings with the exception of configuring `-Dlog4j.configuration.file=...`.
#   Use $logging_config for the latter.
#
# Note: When using a custom namespace/chroot in the ZooKeeper connection string you must manually create the namespace
#       in ZK first (e.g. in 'localhost:2181/kafka' the namespace is '/kafka').
define kafka::broker (
  $broker_id         = 0,
  $broker_port       = 9092,
  $config            = $kafka::params::config,
  $config_map        = {},
  $gc_log_file       = $kafka::params::gc_log_file,
  $jmx_port          = 9999,
  $kafka_gc_log_opts = '-verbose:gc -XX:+PrintGCDetails -XX:+PrintGCDateStamps -XX:+PrintGCTimeStamps',
  $kafka_heap_opts   = '-Xmx256M',
  $kafka_jmx_opts    = '-Dcom.sun.management.jmxremote -Dcom.sun.management.jmxremote.authenticate=false -Dcom.sun.management.jmxremote.ssl=false',
  $kafka_jvm_performance_opts = '-server -XX:+UseCompressedOops -XX:+UseParNewGC -XX:+UseConcMarkSweepGC -XX:+CMSClassUnloadingEnabled -XX:+CMSScavengeBeforeRemark -XX:+DisableExplicitGC -Djava.awt.headless=true',
  $kafka_log4j_opts    = undef,
  $kafka_opts          = undef,
  $log_dirs          = ['/app/kafka-broker-0'],
  $logging_config    = $kafka::params::logging_config,
  $zookeeper_connect = ['localhost:2181'],
) {

  if !is_integer($broker_id) { fail('The $broker_id parameter must be an integer number') }
  if !is_integer($broker_port) { fail('The $broker_port parameter must be an integer number') }
  validate_absolute_path($config)
  validate_hash($config_map)
  validate_absolute_path($gc_log_file)
  if !is_integer($jmx_port) { fail('The $jmx_port parameter must be an integer number') }
  validate_string($kafka_gc_log_opts)
  validate_string($kafka_heap_opts)
  validate_string($kafka_jmx_opts)
  validate_string($kafka_jvm_performance_opts)
  validate_string($kafka_log4j_opts)
  validate_string($kafka_opts)
  validate_array($log_dirs)
  validate_absolute_path($logging_config)
  validate_array($zookeeper_connect)

  # These 'log' directories are used to store the actual data being sent to Kafka.  Do not confuse them with logging
  # directories such as /var/log/*.
  kafka::broker::create_log_dirs { $log_dirs: }

  file { $config:
    ensure  => file,
    owner   => root,
    group   => root,
    mode    => '0644',
    content => template($kafka::config_template),
    require => [ Package['kafka'], File[$log_dirs] ],
  }

  file { $logging_config:
    ensure  => file,
    owner   => root,
    group   => root,
    mode    => '0644',
    content => template($kafka::logging_config_template),
    require => Class['kafka::install'],
  }

  if !($kafka::service_ensure in ['present', 'absent']) {
    fail('service_ensure parameter must be "present" or "absent"')
  }

  if $kafka::service_manage == true {

    $kafka_gc_log_opts_prefix = "-Xloggc:${gc_log_file}"
    if $kafka_gc_log_opts {
      $kafka_gc_log_opts_real = "KAFKA_GC_LOG_OPTS=\"${kafka_gc_log_opts_prefix} ${kafka_gc_log_opts}\""
    }
    else {
      $kafka_gc_log_opts_real = "KAFKA_GC_LOG_OPTS=\"${kafka_gc_log_opts_prefix}\""
    }

    if $kafka_heap_opts {
      $kafka_heap_opts_real = "KAFKA_HEAP_OPTS=\"${kafka_heap_opts}\""
    }
    else {
      $kafka_heap_opts_real = ''
    }

    if $kafka_jmx_opts {
      $kafka_jmx_opts_real = "KAFKA_JMX_OPTS=\"${kafka_jmx_opts}\""
    }
    else {
      $kafka_jmx_opts_real = ''
    }

    if $kafka_jvm_performance_opts {
      $kafka_jvm_performance_opts_real = "KAFKA_JVM_PERFORMANCE_OPTS=\"${kafka_jvm_performance_opts}\""
    }
    else {
      $kafka_jvm_performance_opts_real = ''
    }

    $kafka_log4j_opts_prefix = "-Dlog4j.configuration=file:${logging_config}"
    if $kafka_log4j_opts {
      $kafka_log4j_opts_real = "KAFKA_LOG4J_OPTS=\"${kafka_log4j_opts_prefix} ${kafka_log4j_opts}\""
    }
    else {
      $kafka_log4j_opts_real = "KAFKA_LOG4J_OPTS=\"${kafka_log4j_opts_prefix}\""
    }

    if $kafka_opts {
      $kafka_opts_real = "KAFKA_OPTS=\"${kafka_opts}\""
    }
    else {
      $kafka_opts_real = ''
    }

    $service_name_real = "${kafka::service_name_prefix}-${broker_id}"

    supervisor::service { $service_name_real:
        ensure                 => $kafka::service_ensure,
        enable                 => $kafka::service_enable,
        command                => "${kafka::command} ${config}",
        directory              => '/',
        environment            => "JMX_PORT=${jmx_port},${kafka_gc_log_opts_real},${kafka_heap_opts_real},${kafka_jmx_opts_real},${kafka_jvm_performance_opts_real},${kafka_log4j_opts_real},${kafka_opts_real}",
        user                   => $kafka::user,
        group                  => $kafka::group,
        autorestart            => $kafka::service_autorestart,
        startsecs              => $kafka::service_startsecs,
        retries                => $kafka::service_retries,
        stdout_logfile_maxsize => $kafka::service_stdout_logfile_maxsize,
        stdout_logfile_keep    => $kafka::service_stdout_logfile_keep,
        stderr_logfile_maxsize => $kafka::service_stderr_logfile_maxsize,
        stderr_logfile_keep    => $kafka::service_stderr_logfile_keep,
        stopsignal             => 'INT',
        stopasgroup            => true,
        require                => [
          Class['kafka::install'],
          File[$config],
          File[$log_dirs],
          File[$logging_config],
          Class['::supervisor'],
        ],
    }

    if $kafka::service_enable == true {
      exec { "restart-kafka-broker-${broker_id}":
        command     => "supervisorctl restart ${service_name_real}",
        path        => ['/usr/bin', '/usr/sbin', '/sbin', '/bin'],
        user        => 'root',
        refreshonly => true,
        subscribe   => File[$config],
        onlyif      => 'which supervisorctl &>/dev/null',
        require     => Class['::supervisor'],
      }
    }

  }

}
