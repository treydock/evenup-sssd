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

  if 'autofs' in $sssd::services {
    $_autofs_ensure = 'present'
  } else {
    $_autofs_ensure = 'absent'
  }

  if 'sudo' in $sssd::services {
    $_sudo_ensure = 'present'
  } else {
    $_sudo_ensure = 'absent'
  }

  if 'ssh' in $sssd::services {
    $_ssh_ensure = 'present'
  } else {
    $_ssh_ensure = 'absent'
  }

  resources { 'sssd_config':
    purge => $sssd::sssd_config_purge,
  }

  resources { 'sssd_domain_config':
    purge => $sssd::sssd_domain_config_purge,
  }

  if $sssd::use_puppet_certs {
    file { 'sssd_ldap_tls_cacert':
      ensure  => 'present',
      path    => $sssd::ldap_tls_cacert_real,
      #content => x509_to_text($settings::localcacert),
      content => undef,
      source  => "file://${settings::localcacert}",
      owner   => 'root',
      group   => 'root',
      mode    => '0644',
      notify  => Service['sssd'],
    }
  }

  file { '/etc/sssd/sssd.conf':
    ensure => 'file',
    owner  => 'root',
    group  => 'root',
    mode   => '0600',
    notify => Service['sssd'],
  }

  sssd_config { 'sssd/config_file_version': value => '2' }
  sssd_config { 'sssd/services': value => join($sssd::services, ',') }
  sssd_config { 'sssd/domains': value => 'LDAP' }

  sssd_config { 'nss/filter_groups': value => $sssd::filter_groups }
  sssd_config { 'nss/filter_users': value => $sssd::filter_users }

  sssd_config { 'pam/offline_credentials_expiration': value => '0' }

  # set autofs config so section exists
  sssd_config { 'autofs/debug_level': ensure => $_autofs_ensure, value => '0' }

  # set sudo config so section exists
  sssd_config { 'sudo/debug_level': ensure => $_sudo_ensure, value => '0' }

  # set ssh config so section exists
  sssd_config { 'ssh/debug_level': ensure => $_ssh_ensure, value => '0' }

  sssd_domain_config { 'LDAP/cache_credentials': value => true }
  sssd_domain_config { 'LDAP/enumerate': value => $sssd::ldap_enumerate }
  sssd_domain_config { 'LDAP/id_provider': value => 'ldap' }
  sssd_domain_config { 'LDAP/auth_provider': value => 'ldap' }
  sssd_domain_config { 'LDAP/chpass_provider': value => 'ldap' }
  sssd_domain_config { 'LDAP/access_provider': value => 'ldap' }
  sssd_domain_config { 'LDAP/autofs_provider': ensure => $_autofs_ensure, value => 'ldap' }
  sssd_domain_config { 'LDAP/sudo_provider': ensure => $_sudo_ensure, value => 'ldap' }
  sssd_domain_config { 'LDAP/ldap_uri': value => join($sssd::ldap_uri_array, ',') }
  sssd_domain_config { 'LDAP/ldap_search_base': value => $sssd::ldap_base }
  sssd_domain_config { 'LDAP/ldap_tls_reqcert': value => $sssd::ldap_tls_reqcert }
  sssd_domain_config { 'LDAP/ldap_tls_cacert': value => $sssd::ldap_tls_cacert_real }
  sssd_domain_config { 'LDAP/ldap_schema': value => $sssd::ldap_schema }
  sssd_domain_config { 'LDAP/ldap_group_member': value => $sssd::ldap_group_member }
  sssd_domain_config { 'LDAP/ldap_pwd_policy': value => $sssd::ldap_pwd_policy }
  sssd_domain_config { 'LDAP/ldap_account_expire_policy': value => $sssd::ldap_account_expire_policy }
  sssd_domain_config { 'LDAP/ldap_access_order': value => 'filter,expire' }
  sssd_domain_config { 'LDAP/ldap_access_filter': value => $sssd::ldap_access_filter }

  sssd_domain_config { 'LDAP/ldap_autofs_search_base': ensure => $_autofs_ensure, value => $sssd::ldap_autofs_search_base_real }
  sssd_domain_config { 'LDAP/ldap_sudo_search_base': ensure => $_sudo_ensure, value => $sssd::ldap_sudo_search_base_real }

  create_resources('sssd_config', $sssd::sssd_configs)
  create_resources('sssd_domain_config', $sssd::sssd_domain_configs)

  if $sssd::manage_pam_config {
    file { '/etc/pam.d/password-auth':
      ensure => link,
      target => 'password-auth-ac',
    }

    file { '/etc/pam.d/password-auth-ac':
      ensure  => file,
      owner   => 'root',
      group   => 'root',
      mode    => '0444',
      content => template('sssd/password-auth-ac.erb'),
    }

    file { '/etc/pam.d/system-auth':
      ensure => link,
      target => 'system-auth-ac',
    }

    file { '/etc/pam.d/system-auth-ac':
      ensure  => file,
      owner   => 'root',
      group   => 'root',
      mode    => '0444',
      content => template('sssd/system-auth-ac.erb'),
    }
  }

  if $sssd::manage_nsswitch {
    file { '/etc/nsswitch.conf':
      ensure  => file,
      owner   => 'root',
      group   => 'root',
      mode    => '0444',
      content => template('sssd/nsswitch.conf.erb'),
    }
  }

  if member($sssd::services, 'autofs') {
    file { '/etc/autofs_ldap_auth.conf':
      ensure  => file,
      owner   => 'root',
      group   => 'root',
      mode    => '0600',
      content => template('sssd/autofs_ldap_auth.conf.erb'),
      notify  => Service['autofs'],
    }
  }

  case $sssd::logsagent {
    'beaver': {
      beaver::stanza { '/var/log/sssd/sssd_LDAP.log':
        type => 'sssd',
        tags => ['sssd', 'ldap', $::disposition],
      }

      beaver::stanza { '/var/log/sssd/sssd.log':
        type => 'sssd',
        tags => ['sssd', $::disposition],
      }

      beaver::stanza { '/var/log/sssd/sssd_nss.log':
        type => 'sssd',
        tags => ['sssd', 'nss', $::disposition],
      }

      beaver::stanza { '/var/log/sssd/sssd_pam.log':
        type => 'sssd',
        tags => ['sssd', 'pam', $::disposition],
      }
    }
    default: {}
  }


}
