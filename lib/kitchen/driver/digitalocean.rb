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
require 'json'

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
      default_config :user_data, nil

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

          break if droplet && droplet.networks[:v4] && droplet.networks[:v4].any? { |n| n[:type] == 'public' }
        end
        droplet ||= client.droplets.find(id: state[:server_id])

        state[:hostname] = droplet.networks[:v4]
                           .find { |n| n[:type] == 'public' }['ip_address']

        wait_for_sshd(state[:hostname]); print "(ssh ready)\n"
        debug("digitalocean:create #{state[:hostname]}")
      end

      def destroy(state)
        return if state[:server_id].nil?

        # A new droplet cannot be destroyed before it is active
        # Retry destroying the droplet as long as its status is "new"
        loop do
          droplet = client.droplets.find(id: state[:server_id])

          break if !droplet
          if droplet.status != 'new'
            client.droplets.delete(id: state[:server_id])
            break
          end

          info("Waiting on Digital Ocean instance <#{state[:server_id]}> to be active to destroy it, retrying in 8 seconds")
          sleep 8
        end

        info("Digital Ocean instance <#{state[:server_id]}> destroyed.")
        state.delete(:server_id)
        state.delete(:hostname)
      end

      # This method attempts to fetch the platform from a list of well-known
      # platform => slug mappings, and falls back to using just the platform as
      # provided if it can't find a mapping.
      def default_image
        platform_to_slug_mapping.fetch(instance.platform.name,
                                       instance.platform.name)
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
          (Etc.getlogin || 'nologin').gsub(/\W/, '')[0..14],
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
          ssh_keys: config[:ssh_key_ids].to_s.split(/, ?/),
          private_networking: config[:private_networking],
          ipv6: config[:ipv6],
          user_data: config[:user_data]
        )

        resp = client.droplets.create(droplet)

        if resp.class != DropletKit::Droplet
          error JSON.parse(resp)['message']
          error 'Please check your access token is set correctly.'
        else
          resp
        end
      end

      def debug_server_config
        debug("digitalocean:name #{config[:server_name]}")
        debug("digitalocean:image#{config[:image]}")
        debug("digitalocean:size #{config[:size]}")
        debug("digitalocean:region #{config[:region]}")
        debug("digitalocean:ssh_key_ids #{config[:ssh_key_ids]}")
        debug("digitalocean:private_networking #{config[:private_networking]}")
        debug("digitalocean:ipv6 #{config[:ipv6]}")
        debug("digitalocean:user_data #{config[:user_data]}")
      end

      def debug_client_config
        debug("digitalocean_api_key #{config[:digitalocean_access_token]}")
      end

      def platform_to_slug_mapping
        {
          'centos-5.10'    => 'centos-5-8-x64',
          'centos-6.7'     => 'centos-6-7-x64',
          'centos-7.1'     => 'centos-7-1-x64',
          'coreos-835.9.0' => 'coreos-835.9.0-x64',
          'coreos-877.1.0' => 'coreos-877.1.0-x64',
          'coreos-891.0.0' => 'coreos-891.0.0-x64',
          'debian-6.0'     => 'debian-6-0-x64',
          'debian-7.9'     => 'debian-7-9-x64',
          'debian-8.2'     => 'debian-8-2-x64',
          'fedora-21'      => 'fedora-21-x64',
          'fedora-22'      => 'fedora-22-x64',
          'fedora-23'      => 'fedora-23-x64',
          'freebsd-10.1'   => 'freebsd-10-1-x64',
          'freebsd-10.2'   => 'freebsd-10-2-x64',
          'ubuntu-12.04.5' => 'ubuntu-12-04-5-x64',
          'ubuntu-14.04.3' => 'ubuntu-14-04-3-x64',
          'ubuntu-15.04'   => 'ubuntu-15-04-x64',
          'ubuntu-15.10'   => 'ubuntu-15-10-x64'
        }
      end
    end
  end
end

# vim: ai et ts=2 sts=2 sw=2 ft=ruby
