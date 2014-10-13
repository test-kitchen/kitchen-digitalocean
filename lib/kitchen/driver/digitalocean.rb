# -*- encoding: utf-8 -*-
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

require 'benchmark'
require 'droplet_kit'
require 'kitchen'
require 'etc'
require 'socket'

module Kitchen
  module Driver
    # Digital Ocean driver for Kitchen.
    #
    # @author Greg Fitzgerald <greg@gregf.org>
    class Digitalocean < Kitchen::Driver::SSHBase
      default_config :username, 'root'
      default_config :port, '22'
      default_config :region, 'nyc2'
      default_config :size, '512mb'
      default_config(:image) { |driver| driver.default_image }
      default_config(:server_name) { |driver| driver.default_name }
      default_config :private_networking, true
      default_config :ipv6, false

      default_config :digitalocean_access_token do
        ENV['DIGITALOCEAN_ACCESS_TOKEN']
      end

      default_config :ssh_key_ids do
        ENV['DIGITALOCEAN_SSH_KEY_IDS'] || ENV['SSH_KEY_IDS']
      end

      required_config :digitalocean_access_token
      required_config :ssh_key_ids

      def create(state)
        server = create_server
        state[:server_id] = server.id

        info("Digital Ocean instance <#{state[:server_id]}> created.")

        loop do
          sleep 8
          droplet = client.droplets.find(id: state[:server_id])

          break if droplet \
            && droplet.networks[:v4] \
            && droplet.networks[:v4].any? { |n| n[:type] == 'public' }
        end

        state[:hostname] = droplet.networks[:v4]
          .find { |n| n[:type] == 'public' }['ip_address']

        wait_for_sshd(state[:hostname]); print "(ssh ready)\n"
        debug("digitalocean:create #{state[:hostname]}")
      end

      def destroy(state)
        return if state[:server_id].nil?

        client.droplets.delete(id: state[:server_id])
        info("Digital Ocean instance <#{state[:server_id]}> destroyed.")
        state.delete(:server_id)
        state.delete(:hostname)
      end

      def default_image
        instance.platform.name
      end

      # Generate what should be a unique server name up to 63 total chars
      # Base name:    15
      # Username:     15
      # Hostname:     23
      # Random string: 7
      # Separators:    3
      # ================
      # Total:        63
      def default_name
        [
          instance.name.gsub(/\W/, '')[0..14],
          Etc.getlogin.gsub(/\W/, '')[0..14],
          Socket.gethostname.gsub(/\W/, '')[0..22],
          Array.new(7) { rand(36).to_s(36) }.join
        ].join('-').gsub(/_/, '-')
      end

      private

      def client
        debug_client_config

        DropletKit::Client.new(access_token: config[:digitalocean_access_token])
      end

      def create_server
        debug_server_config

        droplet = DropletKit::Droplet.new(
          name: config[:server_name],
          region: config[:region],
          image: config[:image],
          size: config[:size],
          ssh_keys: config[:ssh_key_ids].split(' '),
          private_networking: config[:private_networking],
          ipv6: config[:ipv6]
        )

        client.droplets.create(droplet)
      end

      def debug_server_config
        debug("digitalocean:name #{config[:server_name]}")
        debug("digitalocean:image#{config[:image]}")
        debug("digitalocean:size #{config[:size]}")
        debug("digitalocean:region #{config[:region]}")
        debug("digitalocean:ssh_key_ids #{config[:ssh_key_ids]}")
        debug("digitalocean:private_networking #{config[:private_networking]}")
        debug("digitalocean:ipv6 #{config[:ipv6]}")
      end

      def debug_client_config
        debug("digitalocean_api_key #{config[:digitalocean_access_token]}")
      end
    end
  end
end

# vim: ai et ts=2 sts=2 sw=2 ft=ruby
