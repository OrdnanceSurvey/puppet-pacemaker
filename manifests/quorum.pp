class pacemaker::quorum ( 
  $ignore  = undef,
  $freeze  = undef,
  $stop    = undef,
  $suicide = undef,
) {
  if $ignore == true {
    exec {"Ignore QUORUM":
        command => "/usr/sbin/pcs property set no-quorum-policy=ignore",
        unless => "/usr/sbin/pcs property show no-quorum-policy | grep 'no-quorum-policy: ignore'",
        require => [ Exec["wait-for-settle"],
                     Class['::pacemaker::corosync']
                   ],
    }
  }
  elsif $freeze == true {
    exec {"Freeze QUORUM":
        command => "/usr/sbin/pcs property set no-quorum-policy=freeze",
        onlyif => "/usr/sbin/pcs property show no-quorum-policy | grep 'no-quorum-policy: freeze'",
        require => [ Exec["wait-for-settle"],
                     Class['::pacemaker::corosync']
                   ],
    }
  }
  elsif $stop == true {
    exec {"Stop QUORUM":
        command => "/usr/sbin/pcs property set no-quorum-policy=stop",
        onlyif => "/usr/sbin/pcs property show no-quorum-policy | grep 'no-quorum-policy: stop'",
        require => [ Exec["wait-for-settle"],
                     Class['::pacemaker::corosync']
                   ],
    }
  }
  elsif $suicide == true {
    exec {"Suicide QUORUM":
        command => "/usr/sbin/pcs property set no-quorum-policy=suicide",
        onlyif => "/usr/sbin/pcs property show no-quorum-policy | grep 'no-quorum-policy: suicide'",
        require => [ Exec["wait-for-settle"],
                     Class['::pacemaker::corosync']
                   ],
    }
  }
  else {
    exec {"Stop QUORUM":
        command => "/usr/sbin/pcs property set no-quorum-policy=stop",
        onlyif => "/usr/sbin/pcs property show no-quorum-policy | grep 'no-quorum-policy: stop'",
        require => [ Exec["wait-for-settle"],
                     Class['::pacemaker::corosync']
                   ],
    }
  }
}
