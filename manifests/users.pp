# == Class kafka::users
#
class kafka::users inherits kafka {

  if $user_manage == true {

    if $gid != 0 {
      group { $group:
        ensure => $group_ensure,
        gid    => $gid,
      }
    }

    user { $user:
      ensure     => $user_ensure,
      home       => $user_home,
      shell      => $shell,
      uid        => $uid,
      comment    => $user_description,
      groups     => ["$group"],
      managehome => $user_managehome,
#      require    => Group[$group],
    }

  }

}
