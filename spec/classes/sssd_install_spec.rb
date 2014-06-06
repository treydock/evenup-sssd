require 'spec_helper'

describe 'sssd::install' do
  let(:facts) {{:osfamily => 'RedHat'}}

  let(:pre_condition) { "class { 'sssd': }" }

  it { should create_class('sssd::install') }

  it { should contain_package('sssd').with_ensure('latest') }
  it { should contain_package('sssd-client').with_ensure('latest') }
  it { should_not contain_package('libsss_autofs') }
  it { should_not contain_package('autofs') }

  context "when package_ensure => 'installed'" do
    let :pre_condition do
      "class { 'sssd': package_ensure => 'installed' }"
    end

    it { should contain_package('sssd').with_ensure('installed') }
    it { should contain_package('sssd-client').with_ensure('installed') }
  end

  context "when services => ['nss','pam','autofs']" do
    let :pre_condition do
      "class { 'sssd': services => ['nss','pam','autofs'] }"
    end

    it { should contain_package('libsss_autofs').with_ensure('present') }
    it { should contain_package('autofs').with_ensure('present') }
  end

  context "when services => ['nss','pam','sudo']" do
    let :pre_condition do
      "class { 'sssd': services => ['nss','pam','sudo'] }"
    end

    it { should contain_package('libsss_sudo').with_ensure('present') }
  end
end

