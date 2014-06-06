require 'puppet'
require 'puppet/type/sssd_domain_config'

describe 'Puppet::Type.type(:sssd_domain_config)' do
  before :each do
    @sssd_config = Puppet::Type.type(:sssd_domain_config).new(:name => 'vars/foo', :value => 'bar')
  end

  it 'should require a name' do
    expect {
      Puppet::Type.type(:sssd_config).new({})
    }.to raise_error(Puppet::Error, 'Title or name must be provided')
  end

  it 'should not expect a name with whitespace' do
    expect {
      Puppet::Type.type(:sssd_config).new(:name => 'f oo')
    }.to raise_error(Puppet::Error, /Invalid sssd_config/)
  end

  it 'should fail when there is no section' do
    expect {
      Puppet::Type.type(:sssd_config).new(:name => 'foo')
    }.to raise_error(Puppet::Error, /Invalid sssd_config/)
  end

  it 'should not require a value when ensure is absent' do
    Puppet::Type.type(:sssd_config).new(:name => 'vars/foo', :ensure => :absent)
  end

  it 'should require a value when ensure is present' do
    expect {
      Puppet::Type.type(:sssd_config).new(:name => 'vars/foo', :ensure => :present)
    }.to raise_error(Puppet::Error, /Property value must be set/)
  end

  it 'should accept a valid value' do
    @sssd_config[:value] = 'bar'
    @sssd_config[:value].should == 'bar'
  end

  it 'should not accept a value with whitespace' do
    @sssd_config[:value] = 'b ar'
    @sssd_config[:value].should == 'b ar'
  end

  it 'should accept valid ensure values' do
    @sssd_config[:ensure] = :present
    @sssd_config[:ensure].should == :present
    @sssd_config[:ensure] = :absent
    @sssd_config[:ensure].should == :absent
  end

  it 'should not accept invalid ensure values' do
    expect {
      @sssd_config[:ensure] = :latest
    }.to raise_error(Puppet::Error, /Invalid value/)
  end

end
