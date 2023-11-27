lib = File.expand_path("lib", __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "kitchen/driver/digitalocean_version"

Gem::Specification.new do |spec|
  spec.name          = "kitchen-digitalocean"
  spec.version       = Kitchen::Driver::DIGITALOCEAN_VERSION
  spec.authors       = ["Test Kitchen Team"]
  spec.email         = ["help@sous-chefs.org"]
  spec.description   = "A Test Kitchen Driver for Digital Ocean"
  spec.summary       = spec.description
  spec.homepage      = "https://github.com/test-kitchen/kitchen-digitalocean"
  spec.license       = "Apache-2.0"

  spec.files         = `git ls-files`.split($INPUT_RECORD_SEPARATOR).grep(/LICENSE|^lib/)
  spec.require_paths = ["lib"]

  spec.required_ruby_version = ">= 3.0"

  spec.add_dependency "droplet_kit", ">= 3.7", "< 4.0"
  spec.add_dependency "test-kitchen", ">= 1.17", "< 4"
end
