class kafka (
  $command             = $kafka::params::command,
  $config_template     = $kafka::params::config_template,
  $embedded_log_dir    = $kafka::params::embedded_log_dir,
  $gid                 = $kafka::params::gid,
  $group               = $kafka::params::group,
  $group_ensure        = $kafka::params::group_ensure,
  $hostname            = $kafka::params::hostname,
  $limits_manage       = hiera('kafka::limits_manage', $kafka::params::limits_manage),
  $limits_nofile       = $kafka::params::limits_nofile,
  $logging_config_template        = $kafka::params::logging_config_template,
  $package_ensure      = $kafka::params::package_ensure,
  $package_name        = $kafka::params::package_name,
  $service_autorestart = hiera('kafka::service_autorestart', $kafka::params::service_autorestart),
  $service_enable      = hiera('kafka::service_enable', $kafka::params::service_enable),
  $service_ensure      = $kafka::params::service_ensure,
  $service_manage      = hiera('kafka::service_manage', $kafka::params::service_manage),
  $service_name_prefix = $kafka::params::service_name_prefix,
  $service_retries     = $kafka::params::service_retries,
  $service_startsecs   = $kafka::params::service_startsecs,
  $service_stderr_logfile_keep    = $kafka::params::service_stderr_logfile_keep,
  $service_stderr_logfile_maxsize = $kafka::params::service_stderr_logfile_maxsize,
  $service_stdout_logfile_keep    = $kafka::params::service_stdout_logfile_keep,
  $service_stdout_logfile_maxsize = $kafka::params::service_stdout_logfile_maxsize,
  $shell               = $kafka::params::shell,
  $system_log_dir      = $kafka::params::system_log_dir,
  $uid                 = $kafka::params::uid,
  $user                = $kafka::params::user,
  $user_description    = $kafka::params::user_description,
  $user_ensure         = $kafka::params::user_ensure,
  $user_home           = $kafka::params::user_home,
  $user_managehome     = hiera('kafka::user_managehome', $kafka::params::user_managehome),
) inherits kafka::params {

  validate_string($command)
  validate_string($config_template)
  validate_absolute_path($embedded_log_dir)
  if !is_integer($gid) { fail('The $gid parameter must be an integer number') }
  validate_string($group)
  validate_string($group_ensure)
  validate_string($hostname)
  validate_bool($limits_manage)
  if !is_integer($limits_nofile) { fail('The $limits_nofile parameter must be an integer number') }
  validate_string($logging_config_template)
  validate_string($package_ensure)
  validate_string($package_name)
  validate_bool($service_autorestart)
  validate_bool($service_enable)
  validate_string($service_ensure)
  validate_bool($service_manage)
  validate_string($service_name_prefix)
  if !is_integer($service_retries) { fail('The $service_retries parameter must be an integer number') }
  if !is_integer($service_startsecs) { fail('The $service_startsecs parameter must be an integer number') }
  if !is_integer($service_stderr_logfile_keep) {
    fail('The $service_stderr_logfile_keep parameter must be an integer number')
  }
  validate_string($service_stderr_logfile_maxsize)
  if !is_integer($service_stdout_logfile_keep) {
    fail('The $service_stdout_logfile_keep parameter must be an integer number')
  }
  validate_string($service_stdout_logfile_maxsize)
  validate_absolute_path($shell)
  validate_absolute_path($system_log_dir)
  if !is_integer($uid) { fail('The $uid parameter must be an integer number') }
  validate_string($user)
  validate_string($user_description)
  validate_string($user_ensure)
  validate_absolute_path($user_home)
  validate_bool($user_managehome)

  include '::kafka::install'
  include '::kafka::service'

  # Anchor this as per #8040 - this ensures that classes won't float off and
  # mess everything up. You can read about this at:
  # http://docs.puppetlabs.com/puppet/2.7/reference/lang_containment.html#known-issues
  anchor { 'kafka::begin': }
  anchor { 'kafka::end': }

  Anchor['kafka::begin'] -> Class['::kafka::install'] ~> Class['::kafka::service'] -> Anchor['kafka::end']
}
