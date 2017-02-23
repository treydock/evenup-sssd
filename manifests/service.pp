# == Class: sssd::service
#
# This class manages the sssd service.  It is not intended to be called directly.
#
#
# === Authors
#
# * Justin Lambert <mailto:jlambert@letsevenup.com>
#
#
# === Copyright
#
# Copyright 2013 EvenUp.
#
class sssd::service {

  if $caller_module_name != $module_name {
    fail("Use of private class ${name} by ${caller_module_name}")
  }

  if $sssd::disable_name_service {
    service { 'nslcd':
      ensure => 'stopped',
      enable => false,
      name   => $sssd::params::name_service,
      before => Service['sssd'],
    }
  }

  service { 'sssd':
    ensure     => 'running',
    enable     => true,
    hasstatus  => true,
    hasrestart => true,
  }
}
