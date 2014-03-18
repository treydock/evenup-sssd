require 'spec_helper'

describe "the x509_to_text function" do
  include PuppetlabsSpec::Files

  let(:scope) { PuppetlabsSpec::PuppetInternals.scope }

  it "should exist" do
    Puppet::Parser::Functions.function("x509_to_text").should == "function_x509_to_text"
  end

  it "should raise a ParseError if there is less than 1 arguments" do
    expect { scope.function_x509_to_text([]) }.to raise_error(Puppet::ParseError)
  end

  it "should convert $settings::localcacert file to a plain text certificate" do
    ca_file = tmpfilename('ca.pem')
    File.open(ca_file, 'w') do |fh|
      fh.write(my_fixture_read('ca.pem'))
    end
    result = scope.function_x509_to_text([ca_file])
    result.should == my_fixture_read('ca.crt')
  end
end
