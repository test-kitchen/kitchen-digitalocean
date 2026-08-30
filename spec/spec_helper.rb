# frozen_string_literal: true

#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#    http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

require "rspec"
require "webmock/rspec"

WebMock.disable_net_connect!

require "kitchen/driver/digitalocean"
require "kitchen/driver/digitalocean_version"

Dir[File.expand_path("support/**/*.rb", __dir__)].sort.each { |file| require file }

RSpec.configure do |config|
  config.include DigitalOceanAPI
  config.include KitchenHelpers

  config.expect_with :rspec do |expectations|
    expectations.include_chain_clauses_in_custom_matcher_descriptions = true
    expectations.syntax = :expect
  end

  config.mock_with :rspec do |mocks|
    # Catch doubles that stub methods the real object does not implement.
    mocks.verify_partial_doubles = true
    mocks.syntax = :expect
  end

  config.shared_context_metadata_behavior = :apply_to_host_groups
  config.disable_monkey_patching!
  config.warnings = false
  config.order = :random
  config.filter_run_when_matching :focus
  config.example_status_persistence_file_path = ".rspec_status"

  Kernel.srand config.seed

  # The driver reads DigitalOcean settings from the environment. Snapshot and
  # restore ENV around every example so ordering can never leak configuration
  # between them.
  config.around do |example|
    original = ENV.to_hash
    DigitalOceanAPI::MANAGED_ENV_VARS.each { |key| ENV.delete(key) }
    begin
      example.run
    ensure
      ENV.replace(original)
    end
  end
end
