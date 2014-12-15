require 'spec_helper'

describe 'sssd' do
  let(:facts) {{:osfamily => 'RedHat', :operatingsystemrelease => '6.5'}}

  it { should create_class('sssd') }
  it { should contain_class('sssd::params') }

  it { should contain_class('sssd::install').that_comes_before('Class[sssd::config]') }
  it { should contain_class('sssd::config').that_comes_before('Class[sssd::service]') }
  it { should contain_class('sssd::service').that_comes_before('Anchor[sssd::end]') }

  it { should contain_anchor('sssd::begin').that_comes_before('Class[sssd::install]') }
  it { should contain_anchor('sssd::end') }

  it_behaves_like 'sssd::install'
  it_behaves_like 'sssd::config'
  it_behaves_like 'sssd::service'

  # Test boolean validation
  [
    'ldap_enumerate',
    'use_puppet_certs',
    'make_home_dir',
    'manage_pam_config',
    'manage_nsswitch',
    'disable_name_service',
  ].each do |param|
    context "with #{param} => 'foo'" do
      let(:params) {{ param.to_sym => 'foo' }}
      it { expect { should create_class('sssd') }.to raise_error(Puppet::Error, /is not a boolean/) }
    end
  end

  # Test array validation
  [
    'services',
  ].each do |param|
    context "with #{param} => 'foo'" do
      let(:params) {{ param.to_sym => 'foo' }}
      it { expect { should create_class('sssd') }.to raise_error(Puppet::Error, /is not an Array/) }
    end
  end
end

