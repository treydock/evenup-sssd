# == Class: sssd::params
#
# The sssd configuration settings.
#
# === Authors
#
# Trey Dockendorf <treydock@gmail.com>
#
# === Copyright
#
# Copyright 2014 Trey Dockendorf
#
class sssd::params {

  $ldap_configs = {}

  case $::osfamily {
    'RedHat': {
      $autofs_packages  = ['autofs']
    }

    default: {
      fail("Unsupported osfamily: ${::osfamily}, module ${module_name} only support osfamily RedHat")
    }
  }

}
