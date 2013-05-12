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
require 'fog'
require 'kitchen'
require 'etc'
require 'socket'

module Kitchen
  module Driver
    # Digital Ocean driver for Kitchen.
    #
    # @author Greg Fitzgerald <greg@gregf.org>
    class Digitalocean < Kitchen::Driver::SSHBase
      default_config :image_id, '25489'
      default_config :flavor_id, '66'
      default_config :name, nil
      default_config :ssh_key_ids, nil
      default_config :region_id, '1'
      default_config :username, 'root'
      default_config :port, '22'
      default_config :sudo, false

      def create(state)
        config[:name] ||= generate_name(instance.name)
        server = create_server
        state[:server_id] = server.id

        info("Digital Ocean instance <#{state[:server_id]}> created.")
        server.wait_for { print "."; ready? } ; print "(server ready)"
        state[:hostname] = server.ip_address
        wait_for_sshd(state[:hostname]) ; print "(ssh ready)\n"
      rescue Fog::Errors::Error, Excon::Errors::Error => ex
        raise ActionFailed, ex.message
      end

      def destroy(state)
        return if state[:server_id].nil?

        server = compute.servers.get(state[:server_id])
        server.destroy unless server.nil?
        info("Digital Ocean instance <#{state[:server_id]}> destroyed.")
        state.delete(:server_id)
        state.delete(:hostname)
      end

      private

      def compute
        server_def = {
          :provider               => "Digitalocean",
          :digitalocean_api_key   => config[:digitalocean_api_key],
          :digitalocean_client_id => config[:digitalocean_client_id]
        }
        Fog::Compute.new(server_def)
      end

      def create_server
        compute.servers.create(
          :name         => config[:name],
          :image_id     => config[:image_id],
          :flavor_id    => config[:flavor_id],
          :region_id    => config[:region_id],
          :ssh_key_ids  => config[:ssh_key_ids]
        )
      end

      def generate_name(base)
        # Generate what should be a unique server name
        rand_str = Array.new(8) { rand(36).to_s(36) }.join
        "#{base}-#{Etc.getlogin}-#{Socket.gethostname}-#{rand_str}"
      end
    end
  end
end

# vim: ai et ts=2 sts=2 sw=2 ft=ruby
