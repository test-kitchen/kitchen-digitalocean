# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'kitchen/driver/digitalocean_version'

Gem::Specification.new do |spec|
  spec.name          = 'kitchen-digitalocean'
  spec.version       = Kitchen::Driver::DIGITALOCEAN_VERSION
  spec.authors       = ['Greg Fitzgerald']
  spec.email         = ['greg@gregf.org']
  spec.description   = %q{A Test Kitchen Digital Ocean driver}
  spec.summary       = spec.description
  spec.homepage      = 'https://github.com/gregf/kitchen-digitalocean'
  spec.license       = 'Apache 2.0'

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ['lib']

  spec.add_dependency 'test-kitchen', '~> 1.0.0.alpha'
  spec.add_dependency 'fog', '~> 1.11'

  spec.add_development_dependency 'bundler'
  spec.add_development_dependency 'rake'
  spec.add_development_dependency 'tailor'
  spec.add_development_dependency 'cane'
  spec.add_development_dependency 'countloc'
  spec.add_development_dependency 'rspec'
  spec.add_development_dependency 'multi_json'
end

# vim: ai et ts=2 sts=2 sw=2 ft=ruby
