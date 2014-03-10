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

  $package_ensure   = $sssd::package_ensure
  $with_autofs      = $sssd::with_autofs
  $autofs_packages  = ['libsss_autofs', 'autofs']
  $sudo_packages    = ['libsss_sudo']

  if $caller_module_name != $module_name {
    fail("Use of private class ${name} by ${caller_module_name}")
  }

  package { 'sssd':
    ensure  => $package_ensure,
  }

  package { 'sssd-client':
    ensure  => $package_ensure,
  }

  if $with_autofs {
    ensure_packages($autofs_packages)
  }

  if $with_sudo {
    ensure_packages($sudo_packages)
  }

}
