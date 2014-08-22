# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'kitchen/driver/digitalocean_version'

Gem::Specification.new do |spec|
  spec.name          = 'kitchen-digitalocean'
  spec.version       = Kitchen::Driver::DIGITALOCEAN_VERSION
  spec.authors       = ['Greg Fitzgerald']
  spec.email         = ['greg@gregf.org']
  spec.description   = 'A Test Kitchen Driver for Digital Ocean'
  spec.summary       = spec.description
  spec.homepage      = 'https://github.com/test-kitchen/kitchen-digitalocean'
  spec.license       = 'Apache 2.0'

  spec.files         = `git ls-files`.split($INPUT_RECORD_SEPARATOR)
  spec.executables    = []
  spec.test_files    = spec.files.grep(/^(test|spec|features)/)
  spec.require_paths = ['lib']

  spec.add_dependency 'test-kitchen', '~> 1.2'
  spec.add_dependency 'droplet_kit', '~> 1.0'

  spec.add_development_dependency 'bundler'
  spec.add_development_dependency 'rake'
  spec.add_development_dependency 'rubocop'
  spec.add_development_dependency 'cane'
  spec.add_development_dependency 'countloc'
  spec.add_development_dependency 'rspec'
  spec.add_development_dependency 'webmock'
  spec.add_development_dependency 'simplecov'
  spec.add_development_dependency 'simplecov-console'
  spec.add_development_dependency 'coveralls'
end

# vim: ai et ts=2 sts=2 sw=2 ft=ruby
