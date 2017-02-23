shared_examples_for 'sssd::config' do
  it { should_not contain_file('sssd_ldap_tls_cacert') }

  it do
    should contain_file('/etc/sssd/sssd.conf').with({
      'ensure'  => 'file',
      'owner'   => 'root',
      'group'   => 'root',
      'mode'    => '0600',
      'notify'  => 'Service[sssd]',
    })
  end

  [
    {:config => 'sssd/config_file_version', :ensure => nil, :value => '2'},
    {:config => 'sssd/services', :ensure => nil, :value => 'nss,pam'},
    {:config => 'sssd/domains', :ensure => nil, :value => 'LDAP'},
    {:config => 'nss/filter_groups', :ensure => nil, :value => 'root,wheel'},
    {:config => 'nss/filter_users', :ensure => nil, :value => 'root'},
    {:config => 'pam/offline_credentials_expiration', :ensure => nil, :value => '0'},
    {:config => 'autofs/debug_level', :ensure => 'absent', :value => '0'},
    {:config => 'sudo/debug_level', :ensure => 'absent', :value => '0'},
    {:config => 'ssh/debug_level', :ensure => 'absent', :value => '0'},
  ].each do |c|
    it "sets #{c[:config]}" do
      is_expected.to contain_sssd_config(c[:config]).with_ensure(c[:ensure]).with_value(c[:value])
    end
  end

  [
    {:config => 'LDAP/cache_credentials', :ensure => nil, :value => 'true'},
    {:config => 'LDAP/enumerate', :ensure => nil, :value => 'false'},
    {:config => 'LDAP/id_provider', :ensure => nil, :value => 'ldap'},
    {:config => 'LDAP/auth_provider', :ensure => nil, :value => 'ldap'},
    {:config => 'LDAP/chpass_provider', :ensure => nil, :value => 'ldap'},
    {:config => 'LDAP/access_provider', :ensure => nil, :value => 'ldap'},
    {:config => 'LDAP/autofs_provider', :ensure => 'absent', :value => 'ldap'},
    {:config => 'LDAP/sudo_provider', :ensure => 'absent', :value => 'ldap'},
    {:config => 'LDAP/ldap_uri', :ensure => nil, :value => 'ldap://ldap.example.org'},
    {:config => 'LDAP/ldap_search_base', :ensure => nil, :value => 'dc=example,dc=org'},
    {:config => 'LDAP/ldap_tls_reqcert', :ensure => nil, :value => 'demand'},
    {:config => 'LDAP/ldap_tls_cacert', :ensure => nil, :value => '/etc/pki/tls/certs/ca-bundle.crt'},
    {:config => 'LDAP/ldap_schema', :ensure => nil, :value => 'rfc2307'},
    {:config => 'LDAP/ldap_group_member', :ensure => nil, :value => 'uniquemember'},
    {:config => 'LDAP/ldap_pwd_policy', :ensure => nil, :value => 'shadow'},
    {:config => 'LDAP/ldap_account_expire_policy', :ensure => nil, :value => 'shadow'},
    {:config => 'LDAP/ldap_access_order', :ensure => nil, :value => 'filter,expire'},
    {:config => 'LDAP/ldap_access_filter', :ensure => nil, :value => '(&(objectclass=shadowaccount)(objectclass=posixaccount))'},
    {:config => 'LDAP/ldap_autofs_search_base', :ensure => 'absent', :value => 'cn=automount,dc=example,dc=org'},
    {:config => 'LDAP/ldap_sudo_search_base', :ensure => 'absent', :value => 'ou=sudoers,dc=example,dc=org'},
  ].each do |c|
    it "sets #{c[:config]}" do
      is_expected.to contain_sssd_domain_config(c[:config]).with_ensure(c[:ensure]).with_value(c[:value])
    end
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

    it { is_expected.to contain_sssd_config('nss/filter_groups').with_value('foo,bar')}
  end

  context 'when setting filter_users' do
    let(:params) {{ :filter_users => 'bob,john' }}

    it { is_expected.to contain_sssd_config('nss/filter_users').with_value('bob,john')}
  end

  context 'when setting ldap_enumerate' do
    let(:params) {{ :ldap_enumerate => true }}

    it { is_expected.to contain_sssd_domain_config('LDAP/enumerate').with_value('true')}
  end

  context 'when setting ldap_base' do
    let(:params) {{ :ldap_base => 'dc=company,dc=com' }}

    it { is_expected.to contain_sssd_domain_config('LDAP/ldap_search_base').with_value('dc=company,dc=com')}
  end

  context 'when setting ldap_uri' do
    let(:params) {{ :ldap_uri => 'ldap://ldap.company.com' }}

    it { is_expected.to contain_sssd_domain_config('LDAP/ldap_uri').with_value('ldap://ldap.company.com')}
  end

  context 'when setting ldap_uri Array' do
    let(:params) {{ :ldap_uri => ['ldap://ldap.company.com', 'ldap://ldap2.company.com'] }}

    it { is_expected.to contain_sssd_domain_config('LDAP/ldap_uri').with_value('ldap://ldap.company.com,ldap://ldap2.company.com')}
  end

  context 'when setting ldap_uri comma separated string' do
    let(:params) {{ :ldap_uri => 'ldap://ldap.company.com,ldap://ldap2.company.com' }}

    it { is_expected.to contain_sssd_domain_config('LDAP/ldap_uri').with_value('ldap://ldap.company.com,ldap://ldap2.company.com')}
  end

  context 'when setting ldap_access_filter' do
    let(:params) {{ :ldap_access_filter => 'objectclass=posixaccount' }}

    it { is_expected.to contain_sssd_domain_config('LDAP/ldap_access_filter').with_value('objectclass=posixaccount')}
  end

  context 'when setting ldap_group_member' do
    let(:params) {{ :ldap_group_member => 'memberUid' }}

    it { is_expected.to contain_sssd_domain_config('LDAP/ldap_group_member').with_value('memberUid')}
  end

  context 'when setting ldap_tls_reqcert' do
    let(:params) {{ :ldap_tls_reqcert => 'always' }}

    it { is_expected.to contain_sssd_domain_config('LDAP/ldap_tls_reqcert').with_value('always')}
  end

  context 'when setting ldap_tls_cacert' do
    let(:params) {{ :ldap_tls_cacert => '/tmp/cert' }}

    it { is_expected.to contain_sssd_domain_config('LDAP/ldap_tls_cacert').with_value('/tmp/cert')}
  end

  context 'when setting ldap_schema' do
    let(:params) {{ :ldap_schema => 'rfc2307bis' }}

    it { is_expected.to contain_sssd_domain_config('LDAP/ldap_schema').with_value('rfc2307bis')}
  end

  context 'when setting ldap_pwd_policy' do
    let(:params) {{ :ldap_pwd_policy => 'none' }}

    it { is_expected.to contain_sssd_domain_config('LDAP/ldap_pwd_policy').with_value('none')}
  end

  context 'when setting ldap_account_expire_policy' do
    let(:params) {{ :ldap_account_expire_policy => '389ds' }}

    it { is_expected.to contain_sssd_domain_config('LDAP/ldap_account_expire_policy').with_value('389ds')}
  end

  context 'when make_home_dir => false' do
    let(:params) {{ :make_home_dir => false }}

    it { should contain_file('/etc/pam.d/system-auth-ac').without_content(/.*pam_mkhomedir.so.*/) }
  end

  context "when services => ['nss','pam','autofs']" do
    let(:params) {{ :services => ['nss','pam','autofs'] }}

    it { is_expected.to contain_sssd_config('autofs/debug_level').with_ensure('present') }
    it { is_expected.to contain_sssd_domain_config('LDAP/autofs_provider').with_ensure('present') }
    it { is_expected.to contain_sssd_domain_config('LDAP/ldap_autofs_search_base').with_ensure('present') }

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

      it { is_expected.to contain_sssd_domain_config('LDAP/ldap_autofs_search_base').with_value('cn=automount,dc=company,dc=com') }
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

    it { is_expected.to contain_sssd_config('sudo/debug_level').with_ensure('present') }
    it { is_expected.to contain_sssd_domain_config('LDAP/sudo_provider').with_ensure('present') }
    it { is_expected.to contain_sssd_domain_config('LDAP/ldap_sudo_search_base').with_ensure('present') }

    it { verify_contents(catalogue, '/etc/nsswitch.conf', ['sudoers:    files sss']) }

    context 'when ldap_sudo_search_base => ou=sudoers,dc=company,dc=com' do
      let(:params) {{ :services => ['nss','pam','sudo'], :ldap_sudo_search_base => 'ou=sudoers,dc=company,dc=com' }}

      it { is_expected.to contain_sssd_domain_config('LDAP/ldap_sudo_search_base').with_value('ou=sudoers,dc=company,dc=com') }
    end
  end

  context "when services => ['nss','pam','autofs','sudo']" do
    let(:params) {{ :services => ['nss','pam','autofs','sudo'] }}

    it { is_expected.to contain_sssd_config('sssd/services').with_value('nss,pam,autofs,sudo')}
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
        'source'  => "file://#{Puppet.settings[:localcacert]}",
        'owner'   => 'root',
        'group'   => 'root',
        'mode'    => '0644',
        'notify'  => 'Service[sssd]',
      })
    end

    it { is_expected.to contain_sssd_domain_config('LDAP/ldap_tls_cacert').with_value('/etc/pki/tls/certs/puppet-ca.crt') }
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
