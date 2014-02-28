require 'spec_helper'

describe 'sssd::config', :type => :class do
  let(:pre_condition) { "class { 'sssd': }" }

  let(:facts) { { :concat_basedir => '/var/lib/puppet/concat' } }

  it { should create_class('sssd::config') }

  it do
    should contain_file('/etc/sssd/sssd.conf').with({
      'ensure'  => 'file',
      'owner'   => 'root',
      'group'   => 'root',
      'mode'    => '0600',
      'notify'  => 'Service[sssd]',
    })
  end

  it do
    should contain_file('/etc/pam.d/password-auth').with({
      'ensure'  => 'link',
      'target'  => 'password-auth-ac',
    })
  end

  it do
    should contain_file('/etc/pam.d/password-auth-ac').with({
      'ensure'  => 'file',
      'owner'   => 'root',
      'group'   => 'root',
      'mode'    => '0444',
    })
  end

  it do
    should contain_file('/etc/pam.d/system-auth').with({
      'ensure'  => 'link',
      'target'  => 'system-auth-ac',
    })
  end

  it do
    should contain_file('/etc/pam.d/system-auth-ac').with({
      'ensure'  => 'file',
      'owner'   => 'root',
      'group'   => 'root',
      'mode'    => '0444',
    })
  end

  it do
    should contain_file('/etc/nsswitch.conf').with({
      'ensure'  => 'file',
      'owner'   => 'root',
      'group'   => 'root',
      'mode'    => '0444',
    })
  end

  it { should_not contain_beaver__stanza('/var/log/sssd/sssd_LDAP.log') }
  it { should_not contain_beaver__stanza('/var/log/sssd/sssd.log') }
  it { should_not contain_beaver__stanza('/var/log/sssd/sssd_pam.log') }
  it { should_not contain_beaver__stanza('/var/log/sssd/sssd_nss.log') }

  it do
    content = subject.resource('file', '/etc/sssd/sssd.conf').send(:parameters)[:content]
    content.split("\n").reject { |c| c =~ /(^#|^$)/ }.should == [
      '[sssd]',
      'config_file_version = 2',
      'debug_level = 0x02F0',
      'reconnection_retries = 3',
      'sbus_timeout = 30',
      'services = nss, pam',
      'domains = LDAP',
      '[nss]',
      'debug_level = 0x02F0',
      'reconnection_retries = 3',
      'filter_groups = root,wheel',
      'filter_users = root',
      '[pam]',
      'debug_level = 0x02F0',
      'reconnection_retries = 3',
      'offline_credentials_expiration = 0',
      '[domain/LDAP]',
      'debug_level = 0x02F0',
      'id_provider = ldap',
      'auth_provider = ldap',
      'chpass_provider = ldap',
      'access_provider = ldap',
      'cache_credentials = true',
      'ldap_schema = rfc2307',
      'cache_credentials = true',
      'enumerate = True',
      'entry_cache_timeout = 6000',
      'ldap_id_use_start_tls = true',
      'ldap_search_base = dc=example,dc=org',
      'ldap_uri = ldap://ldap.example.org',
      'ldap_access_filter = (&(objectclass=shadowaccount)(objectclass=posixaccount))',
      'ldap_group_member = uniquemember',
      'ldap_group_object_class = posixGroup',
      'ldap_group_name = cn',
      'ldap_network_timeout = 3',
      'ldap_tls_reqcert = demand',
      'ldap_tls_cacert = /etc/pki/tls/certs/ca-bundle.crt',
      'ldap_chpass_update_last_change = true',
      'ldap_pwd_policy = shadow',
      'ldap_account_expire_policy = shadow',
      'ldap_access_order = expire',
    ]
  end

  it { should contain_file('/etc/sssd/sssd.conf').without_content(/^\[autofs\]$/) }
  it { should contain_file('/etc/sssd/sssd.conf').without_content(/^autofs_provider = ldap$/) }
  it { should contain_file('/etc/sssd/sssd.conf').without_content(/^ldap_autofs_search_base=cn = automount,dc=example,dc=com$/) }
  it { should contain_file('/etc/sssd/sssd.conf').without_content(/^ldap_autofs_map_object_class = automountMap$/) }
  it { should contain_file('/etc/sssd/sssd.conf').without_content(/^ldap_autofs_entry_object_class = automount$/) }
  it { should contain_file('/etc/sssd/sssd.conf').without_content(/^ldap_autofs_map_name = ou$/) }
  it { should contain_file('/etc/sssd/sssd.conf').without_content(/^ldap_autofs_entry_key = cn$/) }
  it { should contain_file('/etc/sssd/sssd.conf').without_content(/^ldap_autofs_entry_value = automountInformation$/) }

  it do
    verify_contents(subject, '/etc/pam.d/password-auth-ac', [
      'auth        required      pam_env.so',
      'auth        sufficient    pam_unix.so nullok try_first_pass',
      'auth        requisite     pam_succeed_if.so uid >= 500 quiet',
      'auth        sufficient    pam_sss.so use_first_pass',
      'auth        required      pam_deny.so',
      'account     required      pam_unix.so',
      'account     sufficient    pam_localuser.so',
      'account     sufficient    pam_succeed_if.so uid < 500 quiet',
      'account     [default=bad success=ok user_unknown=ignore] pam_sss.so',
      'account     required      pam_permit.so',
      'password    requisite     pam_cracklib.so try_first_pass retry=3 type=',
      'password    sufficient    pam_unix.so sha512 shadow nullok try_first_pass use_authtok',
      'password    sufficient    pam_sss.so use_authtok',
      'password    required      pam_deny.so',
      'session     optional      pam_keyinit.so revoke',
      'session     required      pam_limits.so',
      'session     [success=1 default=ignore] pam_succeed_if.so service in crond quiet use_uid',
      'session     required      pam_unix.so',
      'session     optional      pam_sss.so',
    ])
  end

  it do
    verify_contents(subject, '/etc/pam.d/system-auth-ac', [
      'auth        required      pam_env.so',
      'auth        sufficient    pam_unix.so nullok try_first_pass',
      'auth        requisite     pam_succeed_if.so uid >= 500 quiet',
      'auth        sufficient    pam_sss.so use_first_pass',
      'auth        required      pam_deny.so',
      'account     required      pam_unix.so',
      'account     sufficient    pam_localuser.so',
      'account     sufficient    pam_succeed_if.so uid < 500 quiet',
      'account     [default=bad success=ok user_unknown=ignore] pam_sss.so',
      'account     required      pam_permit.so',
      'password    requisite     pam_cracklib.so try_first_pass retry=3 type=',
      'password    sufficient    pam_unix.so sha512 shadow nullok try_first_pass use_authtok',
      'password    sufficient    pam_sss.so use_authtok',
      'password    required      pam_deny.so',
      'session     required      pam_mkhomedir.so umask=0022 skel=/etc/skel/',
      'session     optional      pam_keyinit.so revoke',
      'session     required      pam_limits.so',
      'session     [success=1 default=ignore] pam_succeed_if.so service in crond quiet use_uid',
      'session     required      pam_unix.so',
      'session     optional      pam_sss.so',
    ])
  end

  it { should contain_file('/etc/nsswitch.conf').with_content(/^passwd:     files sss$/)}
  it { should contain_file('/etc/nsswitch.conf').with_content(/^shadow:     files sss$/)}
  it { should contain_file('/etc/nsswitch.conf').with_content(/^group:      files sss$/)}
  it { should contain_file('/etc/nsswitch.conf').with_content(/^automount:  files nisplus$/)}

  context 'when setting filter_groups' do
    let(:pre_condition) { "class { 'sssd': filter_groups => 'foo,bar' }" }

    it { should contain_file('/etc/sssd/sssd.conf').with_content(/filter_groups = foo,bar/)}
  end

  context 'when setting filter_users' do
    let(:pre_condition) { "class { 'sssd': filter_users => 'bob,john' }" }

    it { should contain_file('/etc/sssd/sssd.conf').with_content(/filter_users = bob,john/)}
  end

  context 'when setting ldap_base' do
    let(:pre_condition) { "class { 'sssd': ldap_base => 'dc=company,dc=com' }" }

    it { should contain_file('/etc/sssd/sssd.conf').with_content(/ldap_search_base = dc=company,dc=com/)}
  end

  context 'when setting ldap_uri' do
    let(:pre_condition) { "class { 'sssd': ldap_uri => 'ldap://ldap.company.com' }" }

    it { should contain_file('/etc/sssd/sssd.conf').with_content(/ldap_uri = ldap:\/\/ldap.company.com/)}
  end

  context 'when setting ldap_access_filter' do
    let(:pre_condition) { "class { 'sssd': ldap_access_filter => 'objectclass=posixaccount' }" }

    it { should contain_file('/etc/sssd/sssd.conf').with_content(/ldap_access_filter = objectclass=posixaccount/)}
  end

  context 'when setting ldap_group_member' do
    let(:pre_condition) { "class { 'sssd': ldap_group_member => 'memberUid' }" }

    it { should contain_file('/etc/sssd/sssd.conf').with_content(/ldap_group_member = memberUid/)}
  end

  context 'when setting ldap_tls_reqcert' do
    let(:pre_condition) { "class { 'sssd': ldap_tls_reqcert => 'always' }" }

    it { should contain_file('/etc/sssd/sssd.conf').with_content(/ldap_tls_reqcert = always/)}
  end

  context 'when setting ldap_tls_cacert' do
    let(:pre_condition) { "class { 'sssd': ldap_tls_cacert => '/tmp/cert' }" }

    it { should contain_file('/etc/sssd/sssd.conf').with_content(/ldap_tls_cacert = \/tmp\/cert/)}
  end

  context 'when setting ldap_schema' do
    let(:pre_condition) { "class { 'sssd': ldap_schema => 'rfc2307bis' }" }

    it { should contain_file('/etc/sssd/sssd.conf').with_content(/^ldap_schema = rfc2307bis$/)}
  end

  context 'when logsagent => beaver' do
    let(:pre_condition) { "class { 'sssd': logsagent => 'beaver' }" }

    it { should contain_beaver__stanza('/var/log/sssd/sssd_LDAP.log') }
    it { should contain_beaver__stanza('/var/log/sssd/sssd.log') }
    it { should contain_beaver__stanza('/var/log/sssd/sssd_pam.log') }
    it { should contain_beaver__stanza('/var/log/sssd/sssd_nss.log') }
  end

  context 'when make_home_dir => false' do
    let(:pre_condition) { "class { 'sssd': make_home_dir => false }" }

    it { should contain_file('/etc/pam.d/system-auth-ac').without_content(/.*pam_mkhomedir.so.*/) }
  end

  context 'when with_autofs => true' do
    let(:pre_condition) { "class { 'sssd': with_autofs => true }" }

    it { should contain_file('/etc/sssd/sssd.conf').with_content(/^services = nss, pam, autofs$/) }
    it { should contain_file('/etc/sssd/sssd.conf').with_content(/^\[autofs\]$/) }
    it { should contain_file('/etc/sssd/sssd.conf').with_content(/^autofs_provider = ldap$/) }
    it { should contain_file('/etc/sssd/sssd.conf').with_content(/^ldap_autofs_search_base=cn = automount,dc=example,dc=com$/) }
    it { should contain_file('/etc/sssd/sssd.conf').with_content(/^ldap_autofs_map_object_class = automountMap$/) }
    it { should contain_file('/etc/sssd/sssd.conf').with_content(/^ldap_autofs_entry_object_class = automount$/) }
    it { should contain_file('/etc/sssd/sssd.conf').with_content(/^ldap_autofs_map_name = ou$/) }
    it { should contain_file('/etc/sssd/sssd.conf').with_content(/^ldap_autofs_entry_key = cn$/) }
    it { should contain_file('/etc/sssd/sssd.conf').with_content(/^ldap_autofs_entry_value = automountInformation$/) }
    it { should contain_file('/etc/nsswitch.conf').with_content(/^automount:  files sss$/)}
  end

end
