# -*- encoding: utf-8 -*-
#
# Author:: Jonathan Hartman (<j@p4nt5.com>)
#
# Copyright (C) 2013, Jonathan Hartman
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

require_relative '../../spec_helper'

require 'logger'
require 'stringio'
require 'rspec'
require 'kitchen'

describe Kitchen::Driver::Digitalocean do
  let(:logged_output) { StringIO.new }
  let(:logger) { Logger.new(logged_output) }
  let(:config) { Hash.new }
  let(:state) { Hash.new }
  let(:instance_name) { 'potatoes' }
  let(:platform_name) { 'ubuntu' }

  let(:instance) do
    double(
      name: instance_name,
      logger: logger,
      to_str: 'instance',
      platform: double(name: platform_name)
    )
  end

  let(:driver) { described_class.new(config) }

  before(:each) do
    allow_any_instance_of(described_class).to receive(:instance)
       .and_return(instance)
    ENV['DIGITALOCEAN_ACCESS_TOKEN'] = 'access_token'
    ENV['DIGITALOCEAN_SSH_KEY_IDS'] = '1234'
  end

  describe '#initialize'do
    context 'default options' do
      it 'defaults to the smallest size' do
        expect(driver[:size]).to eq('512mb')
      end

      it 'defaults to SSH with root user on port 22' do
        expect(driver[:username]).to eq('root')
        expect(driver[:port]).to eq('22')
      end

      it 'defaults to a random server name' do
        expect(driver[:server_name]).to be_a(String)
      end

      it 'defaults to region id 1' do
        expect(driver[:region]).to eq('nyc1')
      end

      it 'defaults to SSH Key Ids from $SSH_KEY_IDS' do
        expect(driver[:ssh_key_ids]).to eq('1234')
      end

      it 'defaults to Access Token from $DIGITALOCEAN_ACCESS_TOKEN' do
        expect(driver[:digitalocean_access_token]).to eq('access_token')
      end
    end

    context 'name is ubuntu-14-04-x64' do
      let(:platform_name) { 'ubuntu-14-04-x64' }

      it 'defaults to the correct image ID' do
        expect(driver[:image]).to eq('ubuntu-14-04-x64')
      end
    end

    context 'platform name matches a known platform => slug mapping' do
      let(:platform_name) { 'ubuntu-17' }

      it 'matches the correct image slug' do
        expect(driver[:image]).to eq('ubuntu-17-04-x64')
      end
    end

    context 'overridden options' do
      config = {
        image: 'debian-7-0-x64',
        size: '1gb',
        ssh_key_ids: '5678',
        username: 'admin',
        port: '2222',
        server_name: 'puppy',
        region: 'ams1'
      }

      let(:config) { config }

      config.each do |key, value|
        it "it uses the overridden #{key} option" do
          expect(driver[key]).to eq(value)
        end
      end
    end
  end

  describe '#create' do
    let(:server) do
      double(id: '1234', wait_for: true,
             public_ip_address: '1.2.3.4')
    end

    let(:driver) { described_class.new(config) }

    before(:each) do
      {
        default_name: 'a_monkey!',
        create_server: server,
        wait_for_sshd: '1.2.3.4'
      }.each do |k, v|
        allow_any_instance_of(described_class).to receive(k).and_return(v)
      end
    end

    context 'username and API key only provided' do
      let(:config) do
        {
          digitalocean_access_token: 'access_token'
        }
      end

      it 'generates a server name in the absence of one' do
        stub_request(:get, 'https://api.digitalocean.com/v2/droplets/1234')
          .to_return(create)
        driver.create(state)
        expect(driver[:server_name]).to eq('a_monkey!')
      end

      it 'gets a proper server ID' do
        stub_request(:get, 'https://api.digitalocean.com/v2/droplets/1234')
          .to_return(create)
        driver.create(state)
        expect(state[:server_id]).to eq('1234')
      end

      it 'gets a proper hostname (IP)' do
        stub_request(:get, 'https://api.digitalocean.com/v2/droplets/1234')
          .to_return(create)
        driver.create(state)
        expect(state[:hostname]).to eq('1.2.3.4')
      end
    end
  end

  describe '#destroy' do
    let(:server_id) { '12345' }
    let(:hostname) { 'example.com' }
    let(:state) { { server_id: server_id, hostname: hostname } }
    let(:server) { double(:nil? => false, :destroy => true) }
    let(:servers) { double(get: server) }
    let(:compute) { double(servers: servers) }

    let(:driver) { described_class.new(config) }

    before(:each) do
      {
        compute: compute
      }.each do |k, v|
        allow_any_instance_of(described_class).to receive(k).and_return(v)
      end
    end

    context 'a live server that needs to be destroyed' do
      it 'destroys the server' do
        stub_request(:get, "https://api.digitalocean.com/v2/droplets/12345")
          .to_return(find)
        stub_request(:delete, 'https://api.digitalocean.com/v2/droplets/12345')
          .to_return(delete)
        expect(state).to receive(:delete).with(:server_id)
        expect(state).to receive(:delete).with(:hostname)
        driver.destroy(state)
      end
    end

    context 'no server ID present' do
      let(:state) { Hash.new }

      it 'does nothing' do
        allow(driver).to receive(:compute)
        expect(driver).not_to receive(:compute)
        expect(state).not_to receive(:delete)
        driver.destroy(state)
      end
    end

    context 'a server that was already destroyed' do
      let(:servers) do
        s = double('servers')
        allow(s).to receive(:get).with('12345').and_return(nil)
        s
      end
      let(:compute) { double(servers: servers) }

      let(:driver) { described_class.new(config) }

      before(:each) do
        {
          compute: compute
        }.each do |k, v|
          allow_any_instance_of(described_class).to receive(k).and_return(v)
        end
      end

      it 'does not try to destroy the server again' do
        stub_request(:get, "https://api.digitalocean.com/v2/droplets/12345")
          .to_return(find)
        stub_request(:delete, 'https://api.digitalocean.com/v2/droplets/12345')
          .to_return(delete)
        allow_message_expectations_on_nil
        driver.destroy(state)
      end
    end
  end

  describe '#create_server' do
    let(:config) do
      {
        server_name: 'hello',
        image: 'debian-7-0-x64',
        size: '1gb',
        region: 'nyc3'
      }
    end
    before(:each) do
      @expected = config.merge(name: config[:server_name])
      @expected.delete_if do |k, _|
        k == :server_name
      end
    end
    let(:droplets) do
      s = double('droplets')
      allow(s).to receive(:create) { |arg| arg }
      s
    end
    let(:client) { double(droplets: droplets) }

    before(:each) do
      allow_any_instance_of(described_class).to receive(:client)
        .and_return(client)
    end

    it 'creates the server using a compute connection' do
      expect(driver.send(:create_server).to_h).to include(@expected)
    end
  end

  describe '#default_name' do
    let(:login) { 'user' }
    let(:hostname) { 'host' }

    before(:each) do
      allow(Etc).to receive(:getlogin).and_return(login)
      allow(Socket).to receive(:gethostname).and_return(hostname)
    end

    it 'generates a name' do
      expect(driver.default_name).to match(/^potatoes-user-host-(\S*)/)
    end

    context 'local node with a long hostname' do
      let(:hostname) { 'ab.c' * 20 }

      it 'limits the generated name to 63 characters' do
        expect(driver.default_name.length).to be <= (63)
      end
    end

    context 'node with a long hostname, username, and base name' do
      let(:login) { 'abcd' * 20 }
      let(:hostname) { 'efgh' * 20 }
      let(:instance_name) { 'ijkl' * 20 }

      it 'limits the generated name to 63 characters' do
        expect(driver.default_name.length).to eq(63)
      end
    end

    context 'a login and hostname with punctuation in them' do
      let(:login) { 'some.u-se-r' }
      let(:hostname) { 'a.host-name' }
      let(:instance_name) { 'a.instance-name' }

      it 'strips out the dots to prevent bad server names' do
        expect(driver.default_name).to_not include('.')
      end

      it 'strips out all but the three hyphen separators' do
        expect(driver.default_name.count('-')).to eq(3)
      end
    end
  end
end

# vim: ai et ts=2 sts=2 sw=2 ft=ruby
