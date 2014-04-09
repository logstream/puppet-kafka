# == Class kafka::params
#
class kafka::params {
  $base_dir            = '/opt/kafka' # Base directory under which the Kafka RPM is installed
  $command             = "${base_dir}/bin/kafka-run-class.sh kafka.Kafka"
  $config              = "${base_dir}/config/server-0.properties"
  $config_template     = 'kafka/server.properties.erb'
  # The logs/ sub-dir is hardcoded in some Kafka scripts, and Kafka will also try to create it if it does not exist.
  # The latter causes problems if Kafka files/dirs are owned by root:root but run as a different user.  For that reason
  # we ensure that this directory exists and is writable by the designated Kafka user.  Our Puppet setup however does
  # not make use of this sub-directory.
  $embedded_log_dir    = "${base_dir}/logs"
  $gc_log_file         = '/var/log/kafka/daemon-gc-0.log'
  $gid                 = 53002
  $global_config_map   = {}
  $group               = 'kafka'
  $group_ensure        = 'present'
  $group_manage        = true
  $hostname            = undef
  $limits_manage       = false
  $limits_nofile       = 65536
  $logging_config      = "${base_dir}/config/log4j-0.properties"
  $logging_config_template        = 'kafka/log4j.properties.erb'
  $package_ensure      = 'present'
  $package_name        = 'kafka'
  $service_autorestart = true
  $service_enable      = true
  $service_ensure      = 'present'
  $service_manage      = true
  $service_name_prefix = 'kafka-broker'
  $service_retries     = 999
  $service_startsecs   = 10
  $service_stderr_logfile_keep    = 10
  $service_stderr_logfile_maxsize = '20MB'
  $service_stdout_logfile_keep    = 5
  $service_stdout_logfile_maxsize = '20MB'
  $shell               = '/bin/bash'
  $system_log_dir      = '/var/log/kafka'
  $uid                 = 53002
  $user                = 'kafka'
  $user_description    = 'Kafka system account'
  $user_ensure         = 'present'
  $user_home           = '/home/kafka'
  $user_manage         = true
  $user_managehome     = true

  case $::osfamily {
    'RedHat': {}

    default: {
      fail("The ${module_name} module is not supported on a ${::osfamily} based system.")
    }
  }
}
