require 'spec_helper'

describe 'sssd' do
  on_supported_os({
    :supported_os => [
      {
        "operatingsystem" => "RedHat",
        "operatingsystemrelease" => ["6", "7"],
      }
    ]
  }).each do |os, facts|
    context "on #{os}" do
      let(:facts) do
        facts.merge({
          :concat_basedir => '/dne',
        })
      end

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

    end
  end
end

