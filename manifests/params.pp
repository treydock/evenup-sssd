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

  case $::osfamily {
    'RedHat': {
      if versioncmp($::operatingsystemrelease, '7.0') >= 0 {
        $autofs_packages  = ['autofs']
        $sudo_packages    = []
      } else {
        $autofs_packages  = ['libsss_autofs', 'autofs']
        $sudo_packages    = ['libsss_sudo']
      }
    }

    default: {
      fail("Unsupported osfamily: ${::osfamily}, module ${module_name} only support osfamily RedHat")
    }
  }

}
