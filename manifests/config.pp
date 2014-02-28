# == Class: sssd::config
#
# This class configures sssd.  It is not intended to be called directly.
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
class sssd::config {

  if $caller_module_name != $module_name {
    fail("Use of private class ${name} by ${caller_module_name}")
  }

  file { '/etc/sssd/sssd.conf':
    ensure  => 'file',
    owner   => 'root',
    group   => 'root',
    mode    => '0600',
    notify  => Service['sssd'],
    content => template('sssd/sssd.conf.erb'),
  }

  file { '/etc/pam.d/password-auth':
    ensure  => link,
    target  => 'password-auth-ac',
  }

  file { '/etc/pam.d/password-auth-ac':
    ensure  => file,
    owner   => 'root',
    group   => 'root',
    mode    => '0444',
    content => template('sssd/password-auth-ac.erb'),
  }

  file { '/etc/pam.d/system-auth':
    ensure  => link,
    target  => 'system-auth-ac',
  }

  file { '/etc/pam.d/system-auth-ac':
    ensure  => file,
    owner   => 'root',
    group   => 'root',
    mode    => '0444',
    content => template('sssd/system-auth-ac.erb'),
  }

  file { '/etc/nsswitch.conf':
    ensure  => file,
    owner   => 'root',
    group   => 'root',
    mode    => '0444',
    content => template('sssd/nsswitch.conf.erb'),
  }

  case $sssd::logsagent {
    'beaver': {
      beaver::stanza { '/var/log/sssd/sssd_LDAP.log':
        type    => 'sssd',
        tags    => ['sssd', 'ldap', $::disposition],
      }

      beaver::stanza { '/var/log/sssd/sssd.log':
        type    => 'sssd',
        tags    => ['sssd', $::disposition],
      }

      beaver::stanza { '/var/log/sssd/sssd_nss.log':
        type    => 'sssd',
        tags    => ['sssd', 'nss', $::disposition],
      }

      beaver::stanza { '/var/log/sssd/sssd_pam.log':
        type    => 'sssd',
        tags    => ['sssd', 'pam', $::disposition],
      }
    }
    default: {}
  }


}
