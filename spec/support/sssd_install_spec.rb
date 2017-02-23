shared_examples_for 'sssd::install' do
  it { should contain_package('sssd').with_ensure('latest').with_notify('Service[sssd]') }
  it { should contain_package('sssd-client').with_ensure('latest').with_notify('Service[sssd]') }

  context "when package_ensure => 'installed'" do
    let(:params) {{ :package_ensure => 'installed' }}

    it { should contain_package('sssd').with_ensure('installed') }
    it { should contain_package('sssd-client').with_ensure('installed') }
  end
end
