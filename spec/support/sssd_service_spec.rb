shared_examples_for 'sssd::service' do
  it do
    should contain_service('sssd').with({
      'ensure'      => 'running',
      'enable'      => 'true',
      'hasstatus'   => 'true',
      'hasrestart'  => 'true',
    })
  end

  context "when services => ['nss','pam','autofs']" do
    let(:pre_condition) { "class { 'sssd': services => ['nss','pam','autofs'] }" }

    it do
      should contain_service('autofs').with({
        'ensure'      => 'running',
        'enable'      => 'true',
        'hasstatus'   => 'true',
        'hasrestart'  => 'true',
        'require'     => 'Service[sssd]',
        'subscribe'   => ['File[/etc/autofs_ldap_auth.conf]', 'File[/etc/sssd/sssd.conf]'],
      })
    end
  end
end
