# == Class: sssd::install
#
# This class installs sssd.  It is not intended to be called directly.
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
class sssd::install {

  if $caller_module_name != $module_name {
    fail("Use of private class ${name} by ${caller_module_name}")
  }

  package { 'sssd':
    ensure  => $sssd::package_ensure,
  }

  package { 'sssd-client':
    ensure  => $sssd::package_ensure,
  }

  if member($sssd::services, 'autofs') {
    ensure_packages($sssd::params::autofs_packages)
  }

  if member($sssd::services, 'sudo') {
    ensure_packages($sssd::params::sudo_packages)
  }

}
