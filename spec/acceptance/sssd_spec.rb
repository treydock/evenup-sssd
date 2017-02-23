require 'spec_helper_acceptance'

describe 'sssd class' do
  context 'default parameters' do
    it 'should run successfully' do
      pp =<<-EOS
        class { 'sssd':
          configs => {
            'sssd' => {
              'services' => ['nss','pam'],
              'domains' => 'LDAP',
            },
            'domain/LDAP' => {
              'id_provider' => 'ldap',
              'auth_provider' => 'ldap',
            },
          },
        }
      EOS

      apply_manifest(pp, :catch_failures => true)
      apply_manifest(pp, :catch_changes => true)
    end

    describe package('sssd') do
      it { should be_installed }
    end

    describe package('sssd-client') do
      it { should be_installed }
    end

    describe service('sssd') do
      it { should be_enabled }
      it { should be_running }
    end
  end
end
