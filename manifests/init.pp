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
  String $package_ensure              = 'latest',
  Array $services                     = ['nss','pam'],
  String $filter_groups               = 'root,wheel',
  String $filter_users                = 'root',
  String $ldap_enumerate              = false,
  String $ldap_base                   = 'dc=example,dc=org',
  Variant[String, Array] $ldap_uri    = 'ldap://ldap.example.org',
  String $ldap_access_filter          = '(&(objectclass=shadowaccount)(objectclass=posixaccount))',
  String $ldap_group_member           = 'uniquemember',
  String $ldap_tls_reqcert            = 'demand',
  String $ldap_tls_cacert             = 'UNSET',
  Boolean $use_puppet_certs           = false,
  String $ldap_schema                 = 'rfc2307',
  String $ldap_pwd_policy             = 'shadow',
  String $ldap_account_expire_policy  = 'shadow',
  Boolean $make_home_dir              = true,
  Boolean $manage_autofs_service      = true,
  String $ldap_autofs_search_base     = 'UNSET',
  String $autofs_usetls               = 'yes',
  String $autofs_tlsrequired          = 'yes',
  String $autofs_authrequired         = 'no',
  String $ldap_sudo_search_base       = 'UNSET',
  Boolean $manage_openldap_config     = true,
  Boolean $manage_pam_config          = true,
  Boolean $manage_nsswitch            = true,
  Boolean $disable_name_service       = false,
  Hash $ldap_configs                  = $sssd::params::ldap_configs,
) inherits sssd::params {

  $ldap_uri_array = $ldap_uri ? {
    String => split($ldap_uri, ','),
    Array  => $ldap_uri,
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
