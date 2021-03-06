# == Class: pacemaker::corosync
#
# A class to setup a pacemaker cluster
#
# === Parameters
# [*cluster_name*]
#   The name of the cluster (no whitespace)
# [*cluster_members*]
#   A space-separted list of cluster IP's or names
# [*setup_cluster*]
#   If your cluster includes pcsd, this should be set to true for just
#    one node in cluster.  Else set to true for all nodes.
# [*manage_fw*]
#   Manage or not IPtables rules.
# [*settle_timeout*]
#   Timeout to wait for settle.
# [*settle_tries*]
#   Number of tries for settle.
# [*settle_try_sleep*]
#   Time to sleep after each seetle try.

class pacemaker::corosync (
  $cluster_members,
  $cluster_name     = 'clustername',
  $setup_cluster    = true,
  $manage_fw        = true,
  $settle_timeout   = '3600',
  $settle_tries     = '360',
  $settle_try_sleep = '10',
  $hacluster_pwd    = 'CHANGEME',
  $transport        = "",
  $alt_members      = undef
) inherits pacemaker {
  include ::pacemaker::params

  if $manage_fw {
    firewall { '001 corosync mcast':
      proto  => 'udp',
      dport  => ['5404', '5405'],
      action => 'accept',
    }
  }

  if $pcsd_mode {
    if $manage_fw {
      firewall { '001 pcsd':
        proto  => 'tcp',
        dport  => ['2224'],
        action => 'accept',
      }
    }
    Service['pcsd'] ->
    # we have more fragile when-to-start pacemaker conditions with pcsd
    exec { "enable-not-start-$cluster_name": command => "/usr/sbin/pcs cluster enable" } ->
    exec { "Set password for hacluster user on $cluster_name":
      command => "/bin/echo $hacluster_pwd | /usr/bin/passwd --stdin hacluster",
      creates => "$cluster_conf",
      require => Class["::pacemaker::install"],
    } ->
    exec { "auth-successful-across-all-nodes":
      command   => "/usr/sbin/pcs cluster auth $cluster_members -u hacluster -p $hacluster_pwd --force",
      timeout   => $settle_timeout,
      tries     => $settle_tries,
      try_sleep => $settle_try_sleep,
    } ->
    Exec["wait-for-settle"]
  }
  $transporlt_chunk = $transport ? {
    ''      => '',
    default => "--transport ${transport}",
  }

  if $setup_cluster {
     if  $alt_members {

      $members_array = split ($cluster_members,' ')
        $server1 = $members_array[0]
        $server2 = $members_array[1]

      $alt_array = split ($alt_members,' ')
        $server1_alt = $alt_array[0]
        $server2_alt = $alt_array[1]


       if $server1_alt {
	$comma1=","
       }
       else{
        $comma1=""
       }


       if $server2_alt {
         $comma2=","	
       }
       else {
         $comma=""
       }


      $cluster_alt_members = "${server1}${comma1}${server1_alt} ${server2}${comma2}${server2_alt}"

      exec { "Create Cluster $cluster_name":
        creates => "/etc/cluster/cluster.conf",
        command => "/usr/sbin/pcs cluster setup --name $cluster_name $cluster_alt_members $transport_chunk",
        unless  => "/usr/bin/test -f /etc/corosync/corosync.conf",
        require => Class["::pacemaker::install"],
        }
      }
    else {
      exec { "Create Cluster $cluster_name":
        creates => "/etc/cluster/cluster.conf",
        command => "/usr/sbin/pcs cluster setup --name $cluster_name $cluster_members $transport_chunk",
        unless  => "/usr/bin/test -f /etc/corosync/corosync.conf",
        require => Class["::pacemaker::install"],
        before  => Exec["Start Cluster $cluster_name"],
        }
      } 
      exec { "Start Cluster $cluster_name":
        unless  => "/usr/sbin/pcs status >/dev/null 2>&1",
        command => "/usr/sbin/pcs cluster start --all",
        require => Exec["Create Cluster $cluster_name"],
      }

    if $pcsd_mode {
      Exec["auth-successful-across-all-nodes"] ->
      Exec["Create Cluster $cluster_name"]
    }
    Exec["Start Cluster $cluster_name"] ->
    Exec["wait-for-settle"]
  }

  exec { "wait-for-settle":
    timeout   => $settle_timeout,
    tries     => $settle_tries,
    try_sleep => $settle_try_sleep,
    command   => "/usr/sbin/pcs status | grep -q 'partition with quorum' > /dev/null 2>&1",
    unless    => "/usr/sbin/pcs status | grep -q 'partition with quorum' > /dev/null 2>&1",
    notify    => Notify["pacemaker settled"],
  }

  notify { "pacemaker settled": message => "Pacemaker has reported quorum achieved", }
}
