lib = File.expand_path('lib', __dir__)
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
  spec.license       = 'Apache-2.0'

  spec.files         = `git ls-files`.split($INPUT_RECORD_SEPARATOR).grep(/LICENSE|^CHANGELOG|^lib/)
  spec.test_files    = spec.files.grep(/^(test|spec|features)/)
  spec.require_paths = ['lib']

  spec.add_dependency 'droplet_kit', '~> 2.8'
  spec.add_dependency 'test-kitchen', '~> 1.17'

  spec.add_development_dependency 'bundler', '~> 2.0'
  spec.add_development_dependency 'cane', '~> 3.0'
  spec.add_development_dependency 'countloc', '~> 0.4'
  spec.add_development_dependency 'coveralls', '~> 0.8'
  spec.add_development_dependency 'rake'
  spec.add_development_dependency 'rspec', '~> 3.8'
  spec.add_development_dependency 'rubocop', '~> 0.64'
  spec.add_development_dependency 'simplecov', '~> 0.9'
  spec.add_development_dependency 'simplecov-console', '~> 0.2'
  spec.add_development_dependency 'webmock', '~> 3.5'
end

# vim: ai et ts=2 sts=2 sw=2 ft=ruby
