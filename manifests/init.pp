# == Class: sssd
#
# This class installs sssd and configures it for LDAP authentication.  It also
# sets up nsswitch.conf and pam to use sssd for authentication and groups.
#
#
# === Parameters
#
# [*filter_groups*]
#   String.  Groups to filter out of the sssd results
#   Default: root,wheel
#
# [*filter_users*]
#   String.  Users to filter out of the sssd results
#   Default: root
#
# [*ldap_base*]
#   String.  LDAP base to search for LDAP results in
#   Default: dc=example,dc=org
#
# [*ldap_uri*]
#   String.  LDAP URIs to connect to for results.  Comma separated list of hosts.
#   Default: ldap://ldap.example.org
#
# [*ldap_access_filter*]
#   String.  Filter used to search for users
#   Default: (&(objectclass=shadowaccount)(objectclass=posixaccount))
#
# [*logsagent*]
#   String.  Agent for remote log transport
#   Default: ''
#   Valid options: beaver
#
# === Examples
#
# * Installation:
#     class { 'sssd':
#       ldap_base => 'dc=mycompany,dc=com',
#       ldap_uri  => 'ldap://ldap1.mycompany.com, ldap://ldap2.mycompany.com',
#     }
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
class sssd (
  $package_ensure             = 'latest',
  $services                   = ['nss','pam'],
  $filter_groups              = 'root,wheel',
  $filter_users               = 'root',
  $ldap_enumerate             = false,
  $ldap_base                  = 'dc=example,dc=org',
  $ldap_uri                   = 'ldap://ldap.example.org',
  $ldap_access_filter         = '(&(objectclass=shadowaccount)(objectclass=posixaccount))',
  $ldap_group_member          = 'uniquemember',
  $ldap_tls_reqcert           = 'demand',
  $ldap_tls_cacert            = 'UNSET',
  $use_puppet_certs           = false,
  $ldap_schema                = 'rfc2307',
  $ldap_pwd_policy            = 'shadow',
  $ldap_account_expire_policy = 'shadow',
  $logsagent                  = '',
  $make_home_dir              = true,
  $ldap_autofs_search_base    = 'UNSET',
  $autofs_usetls              = 'yes',
  $autofs_tlsrequired         = 'yes',
  $autofs_authrequired        = 'no',
  $ldap_sudo_search_base      = 'UNSET',
  $manage_pam_config          = true,
  $manage_nsswitch            = true,
) inherits sssd::params {

  validate_array($services)
  validate_bool($ldap_enumerate)
  validate_bool($use_puppet_certs)
  validate_bool($make_home_dir)
  validate_bool($manage_pam_config)
  validate_bool($manage_nsswitch)

  $ldap_uri_array = is_string($ldap_uri) ? {
    true    => split($ldap_uri, ','),
    default => $ldap_uri,
  }

  $ldap_tls_cacert_real = $ldap_tls_cacert ? {
    'UNSET' => $use_puppet_certs ? {
      true    => '/etc/pki/tls/certs/puppet-ca.crt',
      false   => '/etc/pki/tls/certs/ca-bundle.crt',
    },
    default => $ldap_tls_cacert,
  }

  $ldap_autofs_search_base_real = $ldap_autofs_search_base ? {
    'UNSET' => "cn=automount,${ldap_base}",
    default => $ldap_autofs_search_base,
  }

  $ldap_sudo_search_base_real = $ldap_sudo_search_base ? {
    'UNSET' => "ou=sudoers,${ldap_base}",
    default => $ldap_sudo_search_base,
  }

  # Containment
  include 'sssd::install'
  include 'sssd::config'
  include 'sssd::service'

  anchor { 'sssd::begin': } ->
  Class['sssd::install'] ->
  Class['sssd::config'] ->
  Class['sssd::service'] ->
  anchor { 'sssd::end': }

}
