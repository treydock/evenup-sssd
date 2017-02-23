shared_examples_for 'sssd::config' do
  it { should_not contain_file('sssd_ldap_tls_cacert') }

  it do
    should contain_file('/etc/sssd/sssd.conf').with({
      'ensure'  => 'file',
      'owner'   => 'root',
      'group'   => 'root',
      'mode'    => '0600',
      'notify'  => 'Service[sssd]',
    })
  end

  it do
    content = catalogue.resource('file', '/etc/sssd/sssd.conf').send(:parameters)[:content]
    content.split("\n").reject { |c| c =~ /(^#|^$)/ }.should == []
  end

  context 'with configs defined' do
    let(:params) {{
      :configs => {
        'domain/LDAP' => {
          'auth_provider' => 'ldap',
          'id_provider' => 'ldap',
        },
        'sssd' => {
          'domains' => 'LDAP',
          'services' => ['nss','pam'],
        },
      }    
    }}

    it do
      content = catalogue.resource('file', '/etc/sssd/sssd.conf').send(:parameters)[:content]
      content.split("\n").reject { |c| c =~ /(^#|^$)/ }.should == [
        '[domain/LDAP]',
        'auth_provider = ldap',
        'id_provider = ldap',
        '[sssd]',
        'domains = LDAP',
        'services = nss, pam',
      ]
    end
  end
end
