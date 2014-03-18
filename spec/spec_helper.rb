require 'rubygems'
require 'puppetlabs_spec_helper/module_spec_helper'

begin
  require 'simplecov'
  require 'coveralls'
  SimpleCov.formatter = Coveralls::SimpleCov::Formatter
  SimpleCov.start do
    add_filter '/spec/'
  end

  at_exit { RSpec::Puppet::Coverage.report! }
rescue Exception => e
  warn "Coveralls disabled"
end

RSpec.configure do |c|
  c.include PuppetlabsSpec::Files
end

at_exit { RSpec::Puppet::Coverage.report! }
