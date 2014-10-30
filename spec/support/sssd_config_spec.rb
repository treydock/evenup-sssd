shared_examples_for 'sssd::config' do
  it { should_not contain_file('sssd_ldap_tls_cacert') }

  it do
    should contain_file('/etc/openldap/ldap.conf').with({
      'ensure'  => 'file',
      'owner'   => 'root',
      'group'   => 'root',
      'mode'    => '0644',
    })
  end

  it do
    content = catalogue.resource('file', '/etc/openldap/ldap.conf').send(:parameters)[:content]
    content.split("\n").reject { |c| c =~ /(^#|^$)/ }.should == [
      'URI ldap://ldap.example.org',
      'BASE dc=example,dc=org',
      'TLS_CACERT /etc/pki/tls/certs/ca-bundle.crt',
      'TLS_REQCERT demand',
    ]
  end

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
    content = catalogue.resource('file', '/etc/sssd/sssd.conf').send(:parameters)[:content]
    content.split("\n").reject { |c| c =~ /(^#|^$)/ }.should == [
      '[sssd]',
      'config_file_version = 2',
      'debug_level = 0x02F0',
      'reconnection_retries = 3',
      'sbus_timeout = 30',
      'services = nss,pam',
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
      'cache_credentials = TRUE',
      'entry_cache_timeout = 6000',
      'enumerate = FALSE',
      'id_provider = ldap',
      'auth_provider = ldap',
      'chpass_provider = ldap',
      'access_provider = ldap',
      'ldap_uri = ldap://ldap.example.org',
      'ldap_search_base = dc=example,dc=org',
      'ldap_network_timeout = 3',
      'ldap_tls_reqcert = demand',
      'ldap_tls_cacert = /etc/pki/tls/certs/ca-bundle.crt',
      'ldap_schema = rfc2307',
      'ldap_id_use_start_tls = TRUE',
      'ldap_chpass_update_last_change = TRUE',
      'ldap_group_member = uniquemember',
      'ldap_group_object_class = posixGroup',
      'ldap_group_name = cn',
      'ldap_pwd_policy = shadow',
      'ldap_account_expire_policy = shadow',
      'ldap_access_order = filter,expire',
      'ldap_access_filter = (&(objectclass=shadowaccount)(objectclass=posixaccount))',
    ]
  end

  it { should contain_file('/etc/sssd/sssd.conf').without_content(/^\[autofs\]$/) }
  it { should contain_file('/etc/sssd/sssd.conf').without_content(/^autofs_provider = ldap$/) }
  it { should contain_file('/etc/sssd/sssd.conf').without_content(/^ldap_autofs_search_base = .*$/) }
  it { should contain_file('/etc/sssd/sssd.conf').without_content(/^ldap_autofs_map_object_class = automountMap$/) }
  it { should contain_file('/etc/sssd/sssd.conf').without_content(/^ldap_autofs_entry_object_class = automount$/) }
  it { should contain_file('/etc/sssd/sssd.conf').without_content(/^ldap_autofs_map_name = ou$/) }
  it { should contain_file('/etc/sssd/sssd.conf').without_content(/^ldap_autofs_entry_key = cn$/) }
  it { should contain_file('/etc/sssd/sssd.conf').without_content(/^ldap_autofs_entry_value = automountInformation$/) }

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
    verify_contents(catalogue, '/etc/pam.d/password-auth-ac', [
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
    verify_contents(catalogue, '/etc/pam.d/system-auth-ac', [
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

  it do
    should contain_file('/etc/nsswitch.conf').with({
      'ensure'  => 'file',
      'owner'   => 'root',
      'group'   => 'root',
      'mode'    => '0444',
    })
  end

  it { verify_contents(catalogue, '/etc/nsswitch.conf', ['passwd:     files sss']) }
  it { verify_contents(catalogue, '/etc/nsswitch.conf', ['shadow:     files sss']) }
  it { verify_contents(catalogue, '/etc/nsswitch.conf', ['group:      files sss']) }
  it { verify_contents(catalogue, '/etc/nsswitch.conf', ['automount:  files']) }
  it { verify_contents(catalogue, '/etc/nsswitch.conf', ['sudoers:    files']) }

  it { should_not contain_file('/etc/autofs_ldap_auth.conf') }

  it { should_not contain_beaver__stanza('/var/log/sssd/sssd_LDAP.log') }
  it { should_not contain_beaver__stanza('/var/log/sssd/sssd.log') }
  it { should_not contain_beaver__stanza('/var/log/sssd/sssd_pam.log') }
  it { should_not contain_beaver__stanza('/var/log/sssd/sssd_nss.log') }

  context 'when setting filter_groups' do
    let(:params) {{ :filter_groups => 'foo,bar' }}

    it { verify_contents(catalogue, '/etc/sssd/sssd.conf', ['filter_groups = foo,bar']) }
  end

  context 'when setting filter_users' do
    let(:params) {{ :filter_users => 'bob,john' }}

    it { verify_contents(catalogue, '/etc/sssd/sssd.conf', ['filter_users = bob,john']) }
  end

  context 'when setting ldap_enumerate' do
    let(:params) {{ :ldap_enumerate => true }}

    it { verify_contents(catalogue, '/etc/sssd/sssd.conf', ['enumerate = TRUE']) }
  end

  context 'when setting ldap_base' do
    let(:params) {{ :ldap_base => 'dc=company,dc=com' }}

    it { verify_contents(catalogue, '/etc/sssd/sssd.conf', ['ldap_search_base = dc=company,dc=com']) }
  end

  context 'when setting ldap_uri' do
    let(:params) {{ :ldap_uri => 'ldap://ldap.company.com' }}

    it { verify_contents(catalogue, '/etc/sssd/sssd.conf', ['ldap_uri = ldap://ldap.company.com']) }
    it { verify_contents(catalogue, '/etc/openldap/ldap.conf', ['URI ldap://ldap.company.com']) }
  end

  context 'when setting ldap_uri Array' do
    let(:params) {{ :ldap_uri => ['ldap://ldap.company.com', 'ldap://ldap2.company.com'] }}

    it { verify_contents(catalogue, '/etc/sssd/sssd.conf', ['ldap_uri = ldap://ldap.company.com,ldap://ldap2.company.com']) }
    it { verify_contents(catalogue, '/etc/openldap/ldap.conf', ['URI ldap://ldap.company.com ldap://ldap2.company.com']) }
  end

  context 'when setting ldap_uri comma separated string' do
    let(:params) {{ :ldap_uri => 'ldap://ldap.company.com,ldap://ldap2.company.com' }}

    it { verify_contents(catalogue, '/etc/sssd/sssd.conf', ['ldap_uri = ldap://ldap.company.com,ldap://ldap2.company.com']) }
    it { verify_contents(catalogue, '/etc/openldap/ldap.conf', ['URI ldap://ldap.company.com ldap://ldap2.company.com']) }
  end

  context 'when setting ldap_access_filter' do
    let(:params) {{ :ldap_access_filter => 'objectclass=posixaccount' }}

    it { verify_contents(catalogue, '/etc/sssd/sssd.conf', ['ldap_access_filter = objectclass=posixaccount']) }
  end

  context 'when setting ldap_group_member' do
    let(:params) {{ :ldap_group_member => 'memberUid' }}

    it { verify_contents(catalogue, '/etc/sssd/sssd.conf', ['ldap_group_member = memberUid']) }
  end

  context 'when setting ldap_tls_reqcert' do
    let(:params) {{ :ldap_tls_reqcert => 'always' }}

    it { verify_contents(catalogue, '/etc/sssd/sssd.conf', ['ldap_tls_reqcert = always']) }
  end

  context 'when setting ldap_tls_cacert' do
    let(:params) {{ :ldap_tls_cacert => '/tmp/cert' }}

    it { verify_contents(catalogue, '/etc/sssd/sssd.conf', ['ldap_tls_cacert = /tmp/cert']) }
  end

  context 'when setting ldap_schema' do
    let(:params) {{ :ldap_schema => 'rfc2307bis' }}

    it { verify_contents(catalogue, '/etc/sssd/sssd.conf', ['ldap_schema = rfc2307bis']) }
  end

  context 'when setting ldap_pwd_policy' do
    let(:params) {{ :ldap_pwd_policy => 'none' }}

    it { verify_contents(catalogue, '/etc/sssd/sssd.conf', ['ldap_pwd_policy = none']) }
  end

  context 'when setting ldap_account_expire_policy' do
    let(:params) {{ :ldap_account_expire_policy => '389ds' }}

    it { verify_contents(catalogue, '/etc/sssd/sssd.conf', ['ldap_account_expire_policy = 389ds']) }
  end

  context 'when logsagent => beaver' do
    let(:params) {{ :logsagent => 'beaver' }}

    it { should contain_beaver__stanza('/var/log/sssd/sssd_LDAP.log') }
    it { should contain_beaver__stanza('/var/log/sssd/sssd.log') }
    it { should contain_beaver__stanza('/var/log/sssd/sssd_pam.log') }
    it { should contain_beaver__stanza('/var/log/sssd/sssd_nss.log') }
  end

  context 'when make_home_dir => false' do
    let(:params) {{ :make_home_dir => false }}

    it { should contain_file('/etc/pam.d/system-auth-ac').without_content(/.*pam_mkhomedir.so.*/) }
  end

  context "when services => ['nss','pam','autofs']" do
    let(:params) {{ :services => ['nss','pam','autofs'] }}

    it do
      verify_contents(catalogue, '/etc/sssd/sssd.conf', [
        'services = nss,pam,autofs',
        '[autofs]',
        'autofs_provider = ldap',
        'ldap_autofs_search_base = cn=automount,dc=example,dc=org',
        'ldap_autofs_map_object_class = automountMap',
        'ldap_autofs_entry_object_class = automount',
        'ldap_autofs_map_name = ou',
        'ldap_autofs_entry_key = cn',
        'ldap_autofs_entry_value = automountInformation',
      ])
    end

    it { verify_contents(catalogue, '/etc/nsswitch.conf', ['automount:  files sss']) }

    it do
      should contain_file('/etc/autofs_ldap_auth.conf').with({
        'ensure'  => 'file',
        'owner'   => 'root',
        'group'   => 'root',
        'mode'    => '0600',
      })
    end

    it do
      verify_contents(catalogue, '/etc/autofs_ldap_auth.conf', [
        '<autofs_ldap_sasl_conf',
        '	usetls="yes"',
        '	tlsrequired="yes"',
        '	authrequired="no"',
        '/>',
      ])
    end

    context 'when ldap_autofs_search_base => cn=automount,dc=company,dc=com' do
      let(:params) {{ :services => ['nss','pam','autofs'], :ldap_autofs_search_base => 'cn=automount,dc=company,dc=com' }}

      it { verify_contents(catalogue, '/etc/sssd/sssd.conf', ['ldap_autofs_search_base = cn=automount,dc=company,dc=com']) }
    end

    context 'when autofs_usetls => "no"' do
      let(:params) {{ :services => ['nss','pam','autofs'], :autofs_usetls => 'no' }}

      it { verify_contents(catalogue, '/etc/autofs_ldap_auth.conf', ['	usetls="no"']) }
    end

    context 'when autofs_tlsrequired => "no"' do
      let(:params) {{ :services => ['nss','pam','autofs'], :autofs_tlsrequired => 'no' }}

      it { verify_contents(catalogue, '/etc/autofs_ldap_auth.conf', ['	tlsrequired="no"']) }
    end

    context 'when autofs_authrequired => "yes"' do
      let(:params) {{ :services => ['nss','pam','autofs'], :autofs_authrequired => 'yes' }}

      it { verify_contents(catalogue, '/etc/autofs_ldap_auth.conf', ['	authrequired="yes"']) }
    end
  end

  context "when services => ['nss','pam','sudo']" do
    let(:params) {{ :services => ['nss','pam','sudo'] }}

    it do
      verify_contents(catalogue, '/etc/sssd/sssd.conf', [
        'services = nss,pam,sudo',
        '[sudo]',
        'sudo_provider = ldap',
        'ldap_sudo_search_base = ou=sudoers,dc=example,dc=org',
      ])
    end

    it { verify_contents(catalogue, '/etc/nsswitch.conf', ['sudoers:    files sss']) }

    context 'when ldap_sudo_search_base => ou=sudoers,dc=company,dc=com' do
      let(:params) {{ :services => ['nss','pam','sudo'], :ldap_sudo_search_base => 'ou=sudoers,dc=company,dc=com' }}

      it { verify_contents(catalogue, '/etc/sssd/sssd.conf', ['ldap_sudo_search_base = ou=sudoers,dc=company,dc=com']) }
    end
  end

  context "when services => ['nss','pam','autofs','sudo']" do
    let(:params) {{ :services => ['nss','pam','autofs','sudo'] }}

    it { verify_contents(catalogue, '/etc/sssd/sssd.conf', ['services = nss,pam,autofs,sudo']) }
  end

  context 'when use_puppet_certs => true' do
    let(:params) {{ :use_puppet_certs => true }}

    before(:each) do
      ca_file = tmpfilename('ca.pem')
      File.open(ca_file, 'w') do |fh|
        fh.write(my_fixture_read('ca.pem'))
      end
      Puppet.settings[:localcacert] = ca_file
    end

    it do
      should contain_file('sssd_ldap_tls_cacert').with({
        'ensure'  => 'present',
        'path'    => '/etc/pki/tls/certs/puppet-ca.crt',
        'owner'   => 'root',
        'group'   => 'root',
        'mode'    => '0644',
        'notify'  => 'Service[sssd]',
      })
    end

    it do
      verify_contents(catalogue, '/etc/sssd/sssd.conf', ['ldap_tls_cacert = /etc/pki/tls/certs/puppet-ca.crt'])
    end
  end

  context 'when manage_pam_config => false' do
    let(:params) {{ :manage_pam_config => false }}
    it { should_not contain_file('/etc/pam.d/password-auth') }
    it { should_not contain_file('/etc/pam.d/password-auth-ac') }
    it { should_not contain_file('/etc/pam.d/system-auth') }
    it { should_not contain_file('/etc/pam.d/system-auth-ac') }
  end

  context 'when manage_nsswitch => false' do
    let(:params) {{ :manage_nsswitch => false }}
    it { should_not contain_file('/etc/nsswitch.conf') }
  end
end
