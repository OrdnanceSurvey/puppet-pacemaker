define pacemaker::stonith::ipmilan (
  $address        = "10.10.10.1",
  $username       = "",
  $password       = "",
  $interval       = "60s",
  $ensure         = "present",
  $pcmk_host_list = "",
  $action         = "",
  $lanplus        = true,) {
  if ($ensure == absent) {
    exec { "Removing stonith::ipmilan ${address}":
      command => "/usr/sbin/pcs stonith delete stonith-ipmilan-${address}",
      onlyif  => "/usr/sbin/pcs stonith show stonith-ipmilan-${address} > /dev/null 2>&1",
      require => Class['pacemaker::corosync'],
    }
  } else {
    $username_chunk = $username ? {
      ''      => '',
      default => "login=${username}",
    }
    $password_chunk = $password ? {
      ''      => '',
      default => "passwd=${password}",
    }
    $pcmk_host_list_chunk = $pcmk_host_list ? {
      ''      => '',
      default => "pcmk_host_list=\"${pcmk_host_list}\"",
    }
    $action_chunk = $action ? {
      ''      => '',
      default => "action=${action}",
    }

    if $lanplus {
      $lanplus_chunk = "lanplus=true"
    }

    exec { "Creating stonith::ipmilan ${address}":
      command => "/usr/sbin/pcs stonith create stonith-ipmilan-${address} fence_ipmilan ${pcmk_host_list_chunk} ipaddr=${address} ${username_chunk} ${password_chunk} ${action_chunk} ${lanplus_chunk} op monitor interval=${interval}",
      unless  => "/usr/sbin/pcs stonith show stonith-ipmilan-${address} > /dev/null 2>&1",
      require => [Class['pacemaker::corosync'], Package["ipmitool"]]
    }
  }
}
