require 'spec_helper'

describe 'sssd::service', :type => :class do
  let(:pre_condition) { "class { 'sssd': }" }

  it { should create_class('sssd::service') }

  it do
    should contain_service('sssd').with({
      'ensure'      => 'running',
      'enable'      => 'true',
      'hasstatus'   => 'true',
      'hasrestart'  => 'true',
    })
  end
end
