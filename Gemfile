source 'https://rubygems.org'

group :development, :test do
  gem 'rake'
  gem 'puppet-lint'
  gem 'rspec-puppet'
  gem 'puppetlabs_spec_helper'
  gem 'travis'
  gem 'travis-lint'
  gem 'puppet-syntax'
end

group :development do
  gem 'beaker',                 :require => false, :git => 'https://github.com/puppetlabs/beaker', :ref => 'dbac20fe9'
  gem 'beaker-rspec',           :require => false
  gem 'vagrant-wrapper',        :require => false
end

gem 'puppet', ENV['PUPPET_VERSION'] || '~> 3.2.0'
