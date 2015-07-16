shared_examples_for 'sssd::install' do
  it { should contain_package('sssd').with_ensure('latest').with_notify('Service[sssd]') }
  it { should contain_package('sssd-client').with_ensure('latest').with_notify('Service[sssd]') }
  it { should_not contain_package('autofs') }

  context "when package_ensure => 'installed'" do
    let(:params) {{ :package_ensure => 'installed' }}

    it { should contain_package('sssd').with_ensure('installed') }
    it { should contain_package('sssd-client').with_ensure('installed') }
  end

  context "when services => ['nss','pam','autofs']" do
    let(:params) {{ :services => ['nss','pam','autofs'] }}

    it { should contain_package('autofs').with_ensure('present') }
  end
end

