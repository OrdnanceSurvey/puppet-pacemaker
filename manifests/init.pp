# == Class: pacemaker
#
# base class for pacemaker
#
# === Parameters
#
# [*pacemaker::params::hacluster_pwd*]
#   String, used as the default for the pacemaker hacluster_pwd variable
#   Default: CHANGEME
#
# === Variables
#
# [*hacluster_pwd*]
#   used to set the password for the hacluster user on the nodes
#   this user will be used in future pacemaker releases for pcsd to
#   communicate between nodes.
#   Default: $pacemaker::params::hacluster_pwd
#
# === Examples
#
# see pacemaker::corosync
#
# === Authors
#
# Dan Radez <dradez@redhat.com>
#
# === Copyright
#
# Copyright 2013 Red Hat Inc.
#

class pacemaker (
  $hacluster_pwd = $pacemaker::params::hacluster_pwd, 
  $package_list  = $pacemaker::params::package_list,
  $cluster_conf  = $pacemaker::params::cluster_conf,
) inherits 
pacemaker::params {
  include ::pacemaker::params

  class { '::pacemaker::install': package_list => $package_list, }
  include ::pacemaker::service
}
