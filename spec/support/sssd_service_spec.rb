shared_examples_for 'sssd::service' do
  it { should_not contain_service('nslcd') }

  it do
    should contain_service('sssd').with({
      'ensure'      => 'running',
      'enable'      => 'true',
      'hasstatus'   => 'true',
      'hasrestart'  => 'true',
    })
  end

  context "when services => ['nss','pam','autofs']" do
    let(:params) {{ :services => ['nss','pam','autofs'] }}

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

  context "when disable_name_service => true" do
    let(:params) {{ :disable_name_service => true }}

    it do
      should contain_service('nslcd').with({
        :ensure => 'stopped',
        :enable => 'false',
        :name   => 'nslcd',
        :before => 'Service[sssd]',
      })
    end
  end
end
