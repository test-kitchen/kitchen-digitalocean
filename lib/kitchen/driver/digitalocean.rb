# frozen_string_literal: true

#
# Author:: Greg Fitzgerald (<greg@gregf.org>)
#
# Copyright (C) 2013, Greg Fitzgerald
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

require "droplet_kit" unless defined?(DropletKit)
require "kitchen"
require "etc" unless defined?(Etc)
require "socket" unless defined?(Socket)

module Kitchen
  # Namespace for Test Kitchen driver plugins.
  module Driver
    # Test Kitchen driver that provisions DigitalOcean Droplets.
    #
    # The driver talks to the DigitalOcean v2 API through
    # {https://github.com/digitalocean/droplet_kit droplet_kit}. {#create}
    # provisions a Droplet and blocks until it has a routable public IPv4
    # address and an SSH transport that answers; {#destroy} tears it back down.
    #
    # @example Minimal `kitchen.yml`
    #   driver:
    #     name: digitalocean
    #
    #   platforms:
    #     - name: ubuntu-24
    #
    # @see https://docs.digitalocean.com/reference/api/api-reference/ DigitalOcean API reference
    # @author Greg Fitzgerald <greg@gregf.org>
    class Digitalocean < Kitchen::Driver::Base
      # Maps short, human friendly Test Kitchen platform names onto the
      # DigitalOcean image slugs they correspond to.
      #
      # A platform name that is not listed here is passed through to the API
      # untouched, so any valid slug (or a numeric private image ID) can be used
      # directly as a platform name.
      #
      # @return [Hash{String=>String}] frozen platform name to image slug map
      # @see #default_image
      PLATFORM_SLUG_MAP = {
        "almalinux-8" => "almalinux-8-x64",
        "almalinux-9" => "almalinux-9-x64",
        "centos-7" => "centos-7-x64",
        "centos-8" => "centos-8-x64",
        "centos-stream-9" => "centos-stream-9-x64",
        "debian-9" => "debian-9-x64",
        "debian-10" => "debian-10-x64",
        "debian-11" => "debian-11-x64",
        "debian-12" => "debian-12-x64",
        "debian-13" => "debian-13-x64",
        "fedora-32" => "fedora-32-x64",
        "fedora-33" => "fedora-33-x64",
        "fedora-41" => "fedora-41-x64",
        "fedora-42" => "fedora-42-x64",
        "freebsd-11" => "freebsd-11-x64-zfs",
        "freebsd-12" => "freebsd-12-x64-zfs",
        "freebsd-13" => "freebsd-13-x64-zfs",
        "freebsd-14" => "freebsd-14-x64-zfs",
        "rockylinux-8" => "rockylinux-8-x64",
        "rockylinux-9" => "rockylinux-9-x64",
        "ubuntu-16" => "ubuntu-16-04-x64",
        "ubuntu-18" => "ubuntu-18-04-x64",
        "ubuntu-20" => "ubuntu-20-04-x64",
        "ubuntu-22" => "ubuntu-22-04-x64",
        "ubuntu-24" => "ubuntu-24-04-x64",
      }.freeze

      # Separator pattern used to turn a delimited configuration string such as
      # `"web, db"` or `"web db"` into a list.
      #
      # @return [Regexp] frozen separator pattern
      # @see #normalize_list
      LIST_SEPARATOR = /\s*,\s*|\s+/

      # Maximum length of a generated server name, chosen to stay inside the
      # 63 octet limit a single DNS label allows.
      #
      # @return [Integer]
      # @see #default_name
      MAX_SERVER_NAME_LENGTH = 63

      default_config :username, "root"
      default_config :port, "22"
      default_config :size, "s-1vcpu-1gb"
      default_config :monitoring, false
      default_config(:image, &:default_image)
      default_config(:server_name, &:default_name)
      default_config :private_networking, true
      default_config :ipv6, false
      default_config :user_data, nil
      default_config :tags, nil
      default_config :firewalls, nil
      default_config :vpcs, nil
      default_config :server_wait_interval, 8
      default_config :server_wait_timeout, 600

      default_config :api_url do
        ENV["DIGITALOCEAN_API_URL"] || "https://api.digitalocean.com"
      end

      default_config :region do
        ENV["DIGITALOCEAN_REGION"] || "nyc1"
      end

      default_config :digitalocean_access_token do
        ENV["DIGITALOCEAN_ACCESS_TOKEN"]
      end

      default_config :ssh_key_ids do
        ENV["DIGITALOCEAN_SSH_KEY_IDS"] || ENV["SSH_KEY_IDS"]
      end

      required_config :digitalocean_access_token
      required_config :ssh_key_ids

      # Provisions a Droplet and waits until it is reachable over SSH.
      #
      # The method is idempotent: if `state` already carries a `:server_id` the
      # Droplet is assumed to exist and nothing is provisioned, which keeps a
      # retried `kitchen create` from orphaning the Droplet made by the run that
      # failed.
      #
      # @param state [Hash] mutable instance state, populated with
      #   `:server_id`, `:hostname`, `:username` and `:port`
      # @return [void]
      # @raise [Kitchen::ActionFailed] if the API rejects the request, or the
      #   Droplet does not get a public IPv4 address before
      #   `config[:server_wait_timeout]` elapses
      def create(state)
        if state[:server_id]
          info("DigitalOcean instance <#{state[:server_id]}> already created.")
          return
        end

        super

        server = create_server
        state[:server_id] = server.id
        info("DigitalOcean instance <#{state[:server_id]}> created.")

        droplet = wait_for_public_ip(state[:server_id])
        state[:hostname] = public_ipv4(droplet)
        state[:username] = config[:username]
        state[:port] = config[:port]

        attach_firewalls(droplet)

        instance.transport.connection(state, &:wait_until_ready)
        info("(ssh ready)")
        debug("digitalocean:create #{state[:hostname]}")
      end

      # Destroys the Droplet recorded in `state`, if there is one.
      #
      # DigitalOcean refuses to delete a Droplet that is still in the `new`
      # status, so the method polls until the Droplet becomes active and only
      # then issues the delete.
      #
      # @param state [Hash] mutable instance state; `:server_id` and
      #   `:hostname` are removed once the Droplet is gone
      # @return [void]
      # @raise [Kitchen::ActionFailed] if the API rejects the request, or the
      #   Droplet does not leave the `new` status before
      #   `config[:server_wait_timeout]` elapses
      def destroy(state)
        server_id = state[:server_id]
        return if server_id.nil?

        droplet = nil
        wait_until(
          "DigitalOcean instance <#{server_id}> to become active so it can be destroyed"
        ) do
          droplet = find_droplet(server_id)
          droplet.nil? || droplet.status != "new"
        end

        if droplet.nil?
          info("DigitalOcean instance <#{server_id}> is already gone.")
        else
          api_call { client.droplets.delete(id: server_id) }
          info("DigitalOcean instance <#{server_id}> destroyed.")
        end

        state.delete(:server_id)
        state.delete(:hostname)
      end

      # Resolves the configured platform name to a DigitalOcean image slug.
      #
      # Looks the platform name up in {PLATFORM_SLUG_MAP} and falls back to the
      # platform name verbatim, so slugs and private image IDs work unchanged.
      #
      # @return [String] a DigitalOcean image slug or ID
      # @see PLATFORM_SLUG_MAP
      def default_image
        PLATFORM_SLUG_MAP.fetch(instance.platform.name, instance.platform.name)
      end

      # Builds a Droplet name that is unique enough to run many instances side
      # by side without collisions.
      #
      # The name is assembled from four hyphen separated parts, each truncated
      # so the total never exceeds {MAX_SERVER_NAME_LENGTH} octets:
      #
      #     instance name  15
      #     login name     15
      #     local hostname 23
      #     random suffix   7
      #     separators      3
      #     ================
      #     total          63
      #
      # Non-word characters are stripped and underscores become hyphens, since
      # DigitalOcean only accepts letters, digits, periods and hyphens.
      #
      # @return [String] a generated Droplet name of at most 63 characters
      def default_name
        [
          instance.name.gsub(/\W/, "")[0..14],
          (Etc.getlogin || "nologin").gsub(/\W/, "")[0..14],
          Socket.gethostname.gsub(/\W/, "")[0..22],
          Array.new(7) { rand(36).to_s(36) }.join,
        ].join("-").tr("_", "-")[0, MAX_SERVER_NAME_LENGTH]
      end

      private

      # Memoized DigitalOcean API client.
      #
      # Memoization matters: every `DropletKit::Client` builds its own Faraday
      # connection, and a single {#create} reaches for the client several times.
      #
      # @return [DropletKit::Client] client bound to the configured token and URL
      def client
        @client ||= begin
          debug_client_config
          DropletKit::Client.new(
            access_token: config[:digitalocean_access_token],
            api_url: config[:api_url]
          )
        end
      end

      # Submits the Droplet create request built from the driver configuration.
      #
      # @return [DropletKit::Droplet] the newly created Droplet
      # @raise [Kitchen::ActionFailed] if the API rejects the request or returns
      #   a response that cannot be read as a Droplet
      def create_server
        debug_server_config

        droplet = DropletKit::Droplet.new(
          name: config[:server_name],
          region: config[:region],
          image: config[:image],
          size: config[:size],
          monitoring: config[:monitoring],
          ssh_keys: normalize_list(config[:ssh_key_ids]),
          private_networking: config[:private_networking],
          ipv6: config[:ipv6],
          user_data: config[:user_data],
          vpc_uuid: config[:vpcs],
          tags: normalize_list(config[:tags])
        )

        response = api_call { client.droplets.create(droplet) }

        unless response.is_a?(DropletKit::Droplet)
          raise ActionFailed, "Could not create the DigitalOcean Droplet: the " \
            "API returned an unexpected response (#{response.inspect}). Please " \
            "check that your access token is set correctly."
        end

        response
      end

      # Polls the API until the Droplet reports a public IPv4 address.
      #
      # @param server_id [String, Integer] ID of the Droplet to poll
      # @return [DropletKit::Droplet] the Droplet, with networking attached
      # @raise [Kitchen::ActionFailed] if no public IPv4 address appears before
      #   `config[:server_wait_timeout]` elapses
      def wait_for_public_ip(server_id)
        droplet = nil

        wait_until("DigitalOcean instance <#{server_id}> to get a public IP address") do
          droplet = find_droplet(server_id)
          !droplet.nil? && !public_ipv4(droplet).nil?
        end

        droplet
      end

      # Extracts the public IPv4 address from a Droplet.
      #
      # @param droplet [DropletKit::Droplet] Droplet to inspect
      # @return [String, nil] the public IPv4 address, or `nil` if the Droplet
      #   has no public v4 network attached yet
      def public_ipv4(droplet)
        networks = droplet.networks
        return nil if networks.nil? || networks.v4.nil?

        network = networks.v4.find { |n| n.type == "public" }
        network&.ip_address
      end

      # Adds the Droplet to every firewall named by `config[:firewalls]`.
      #
      # A firewall ID that the API does not know about is logged and skipped
      # rather than failing the whole converge.
      #
      # @param droplet [DropletKit::Droplet] Droplet to place behind the firewalls
      # @return [void]
      def attach_firewalls(droplet)
        return if config[:firewalls].nil?

        debug("trying to add the firewall by id")
        firewall_ids = normalize_list(config[:firewalls])

        if firewall_ids.nil?
          warn("firewalls attribute is not a String or Array, ignoring")
          return
        end

        debug("firewall : #{firewall_ids.inspect}")

        firewall_ids.each do |firewall_id|
          firewall = find_firewall(firewall_id)

          if firewall.nil?
            warn("firewalls id: '#{firewall_id}' was not found in api, ignoring")
            next
          end

          api_call { client.firewalls.add_droplets([droplet.id], id: firewall.id) }
          debug("firewall added: #{firewall.id}")
        end
      end

      # Looks a Droplet up by ID, treating "not found" as a normal outcome.
      #
      # @param server_id [String, Integer] ID of the Droplet to fetch
      # @return [DropletKit::Droplet, nil] the Droplet, or `nil` if it no longer exists
      # @raise [Kitchen::ActionFailed] for any API error other than a 404
      def find_droplet(server_id)
        api_call(allow_missing: true) { client.droplets.find(id: server_id) }
      end

      # Looks a firewall up by ID, treating "not found" as a normal outcome.
      #
      # @param firewall_id [String] ID of the firewall to fetch
      # @return [DropletKit::Firewall, nil] the firewall, or `nil` if it does not exist
      # @raise [Kitchen::ActionFailed] for any API error other than a 404
      def find_firewall(firewall_id)
        api_call(allow_missing: true) { client.firewalls.find(id: firewall_id) }
      end

      # Runs an API call, converting `droplet_kit` failures into Test Kitchen
      # errors so users see an actionable message instead of a raw backtrace.
      #
      # @param allow_missing [Boolean] when true, a 404 response yields `nil`
      #   instead of raising
      # @yield the API call to run
      # @return [Object, nil] whatever the block returns, or `nil` for a
      #   tolerated 404
      # @raise [Kitchen::ActionFailed] if the API call fails
      def api_call(allow_missing: false)
        yield
      rescue DropletKit::Error => e
        return nil if allow_missing && e.message.to_s.start_with?("404")

        raise ActionFailed, "The DigitalOcean API request failed: #{e.message}"
      end

      # Polls `block` on a fixed interval until it returns a truthy value.
      #
      # The condition is evaluated before the first sleep, so a resource that is
      # already in the desired state costs no extra wall clock time.
      #
      # @param description [String] what is being waited for, used in log output
      #   and in the timeout message
      # @yield the condition to poll
      # @yieldreturn [Boolean] true once waiting should stop
      # @return [void]
      # @raise [Kitchen::ActionFailed] if `config[:server_wait_timeout]` elapses
      #   before the condition holds
      def wait_until(description)
        interval = config[:server_wait_interval].to_f
        deadline = Time.now + config[:server_wait_timeout].to_f

        loop do
          return if yield

          if Time.now >= deadline
            raise ActionFailed, "Timed out after #{config[:server_wait_timeout]} " \
              "seconds waiting for #{description}"
          end

          info("Waiting on #{description}, retrying in #{interval} seconds")
          sleep(interval)
        end
      end

      # Coerces a configuration value into a list of strings.
      #
      # Accepts the delimited strings (`"a,b"`, `"a, b"`, `"a b"`) that
      # `kitchen.yml` tends to produce, as well as native YAML arrays and bare
      # numbers.
      #
      # @param value [String, Array, Numeric, nil] the configuration value
      # @return [Array<String>] the parsed list; empty when `value` is `nil`
      # @return [nil] if `value` is of a type that cannot be read as a list
      def normalize_list(value)
        case value
        when nil then []
        when Array then value.map { |item| item.to_s.strip }.reject(&:empty?)
        when String then value.split(LIST_SEPARATOR).reject(&:empty?)
        when Numeric then [value.to_s]
        end
      end

      # Writes the resolved Droplet configuration to the debug log.
      #
      # @return [void]
      def debug_server_config
        debug("digitalocean:name #{config[:server_name]}")
        debug("digitalocean:image #{config[:image]}")
        debug("digitalocean:size #{config[:size]}")
        debug("digitalocean:monitoring #{config[:monitoring]}")
        debug("digitalocean:region #{config[:region]}")
        debug("digitalocean:ssh_key_ids #{config[:ssh_key_ids]}")
        debug("digitalocean:private_networking #{config[:private_networking]}")
        debug("digitalocean:ipv6 #{config[:ipv6]}")
        debug("digitalocean:user_data #{config[:user_data]}")
        debug("digitalocean:tags #{config[:tags]}")
        debug("digitalocean:firewalls #{config[:firewalls]}")
        debug("digitalocean:vpcs #{config[:vpcs]}")
      end

      # Writes the resolved API client configuration to the debug log.
      #
      # The access token is redacted: Test Kitchen debug logs are routinely
      # pasted into bug reports and CI output.
      #
      # @return [void]
      def debug_client_config
        debug("digitalocean:api_url #{config[:api_url]}")
        debug("digitalocean:access_token #{redacted_access_token}")
      end

      # Renders the access token in a form that is safe to log.
      #
      # Everything but the last four characters is masked, which is enough to
      # tell two tokens apart in a bug report without disclosing either.
      #
      # @return [String] the masked access token
      def redacted_access_token
        token = config[:digitalocean_access_token].to_s
        return "*" * token.length if token.length <= 4

        ("*" * (token.length - 4)) + token[-4..]
      end
    end
  end
end

# vim: ai et ts=2 sts=2 sw=2 ft=ruby
