class pacemaker::install ($ensure = present, $package_list = $pacemaker::params::package_list,) inherits pacemaker::params {


  package { $package_list: ensure => $ensure, }
}
