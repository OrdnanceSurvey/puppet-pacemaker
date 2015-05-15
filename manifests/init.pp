# == Class: pacemaker
#
# base class for pacemaker
#
# === Parameters
#
# see pacemaker::corosync
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
  $package_list  = $pacemaker::params::package_list,
) inherits pacemaker::params {
  include ::pacemaker::params
  class { '::pacemaker::install': package_list => $package_list, }
  include ::pacemaker::service
}
