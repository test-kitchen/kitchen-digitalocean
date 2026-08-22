# frozen_string_literal: true

require "logger"
require "stringio"
require "kitchen"
require "kitchen/transport/base"

# Helpers for standing up a driver the way Test Kitchen itself does.
#
# Rather than stubbing `Kitchen::Driver::Base#instance`, these helpers drive the
# real `finalize_config!` lifecycle hook. That keeps `required_config`
# validation and the lazy `default_config` blocks on the code path under test.
module KitchenHelpers
  # Captures everything the driver logs, so examples can assert on log output.
  #
  # @return [StringIO] the buffer backing {#logger}
  def logged_output
    @logged_output ||= StringIO.new
  end

  # A logger wired to {#logged_output} at debug level.
  #
  # @return [Logger] the instance logger handed to the driver
  def logger
    @logger ||= Logger.new(logged_output).tap { |log| log.level = Logger::DEBUG }
  end

  # Everything the driver has logged so far.
  #
  # @return [String] the accumulated log output
  def log_output
    logged_output.string
  end

  # A verifying double standing in for the SSH connection Test Kitchen yields.
  #
  # @return [RSpec::Mocks::InstanceVerifyingDouble] a transport connection
  def transport_connection
    @transport_connection ||= instance_double(Kitchen::Transport::Base::Connection).tap do |connection|
      allow(connection).to receive(:wait_until_ready)
    end
  end

  # A verifying double standing in for the instance transport.
  #
  # `#connection` yields the connection double so the driver's
  # `connection(state, &:wait_until_ready)` call runs for real.
  #
  # @return [RSpec::Mocks::InstanceVerifyingDouble] a transport
  def transport
    @transport ||= instance_double(Kitchen::Transport::Base).tap do |double|
      allow(double).to receive(:connection) do |_state, &block|
        block&.call(transport_connection)
        transport_connection
      end
    end
  end

  # A verifying double standing in for the Test Kitchen instance.
  #
  # @param name [String] instance name, e.g. `"default-ubuntu-24"`
  # @param platform [String] platform name, resolved to an image slug
  # @return [RSpec::Mocks::InstanceVerifyingDouble] an instance
  def kitchen_instance(name: "default-ubuntu-24", platform: "ubuntu-24")
    instance_double(
      Kitchen::Instance,
      name: name,
      logger: logger,
      to_str: "<#{name}>",
      platform: instance_double(Kitchen::Platform, name: platform),
      suite: instance_double(Kitchen::Suite, name: "default"),
      transport: transport
    )
  end

  # Builds a driver and finalizes it against an instance, exactly as Test
  # Kitchen does when it loads a `kitchen.yml`.
  #
  # Polling intervals default to zero so waiting behaviour can be exercised
  # without the suite spending real time asleep.
  #
  # Both parameters are positional on purpose: a keyword parameter would make
  # Ruby bind `build_driver(username: "admin")` to the keyword instead of to
  # the config hash.
  #
  # @param config [Hash] driver configuration overrides
  # @param instance [Object, nil] instance to finalize against; built if omitted
  # @return [Kitchen::Driver::Digitalocean] a ready to use driver
  def build_driver(config = {}, instance = nil)
    defaults = {
      digitalocean_access_token: "token-abcd",
      ssh_key_ids: "1234",
      server_wait_interval: 0,
      server_wait_timeout: 5,
    }

    Kitchen::Driver::Digitalocean.new(defaults.merge(config))
      .finalize_config!(instance || kitchen_instance)
  end
end
