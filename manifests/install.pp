# == Class kafka::install
#
class kafka::install inherits kafka {

  group { $group:
    ensure => $group_ensure,
    gid    => $gid,
  }

  user { $user:
    ensure     => $user_ensure,
    home       => $user_home,
    shell      => $shell,
    uid        => $uid,
    comment    => $user_description,
    gid        => $group,
    managehome => $user_managehome,
    require    => Group[$group],
  }

  package { 'kafka':
    ensure  => $package_ensure,
    name    => $package_name,
  }

  # We primarily (or only?) create this directory because some Kafka scripts have hard-coded references to it.
  file { $embedded_log_dir:
    ensure  => directory,
    owner   => $kafka::user,
    group   => $kafka::group,
    mode    => '0755',
    require => Package['kafka'],
  }

  file { $system_log_dir:
    ensure  => directory,
    owner   => $kafka::user,
    group   => $kafka::group,
    mode    => '0755',
  }

  if $limits_manage == true {
    limits::fragment {
      "${user}/soft/nofile": value => $limits_nofile;
      "${user}/hard/nofile": value => $limits_nofile;
    }
  }

}
