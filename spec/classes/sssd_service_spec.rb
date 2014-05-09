require 'spec_helper'

describe 'sssd::service' do
  let(:facts) {{:osfamily => 'RedHat'}}

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

  context 'when with_autofs => true' do
    let(:pre_condition) { "class { 'sssd': with_autofs => true }" }

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
