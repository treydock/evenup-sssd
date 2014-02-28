require 'spec_helper'

describe 'sssd', :type => :class do

  it { should create_class('sssd') }

  it { should contain_class('sssd::install') }
  it { should contain_class('sssd::config') }
  it { should contain_class('sssd::service') }

  # Test boolean validation
  [
    'make_home_dir',
    'with_autofs',
  ].each do |param|
    context "with #{param} => 'foo'" do
      let(:params) {{ param.to_sym => 'foo' }}
      it { expect { should create_class('sssd') }.to raise_error(Puppet::Error, /is not a boolean/) }
    end
  end
end

