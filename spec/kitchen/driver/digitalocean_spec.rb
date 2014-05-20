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
  let(:platform_name) { 'ubuntu' }

  let(:instance) do
    double(
      :name => 'potatoes',
      :logger => logger,
      :to_str => 'instance',
      :platform => double(:name => platform_name)
    )
  end

  let(:driver) do
    d = Kitchen::Driver::Digitalocean.new(config)
    d.instance = instance
    d
  end

  before(:each) do
    ENV['DIGITALOCEAN_CLIENT_ID'] = 'clientid'
    ENV['DIGITALOCEAN_API_KEY'] = 'apikey'
    ENV['SSH_KEY_IDS'] = '1234'
  end

  describe '#initialize'do
    context 'default options' do
      it 'defaults to the smallest flavor size' do
        expect(driver[:flavor_id]).to eq('66')
      end

      it 'defaults to SSH with root user on port 22' do
        expect(driver[:username]).to eq('root')
        expect(driver[:port]).to eq('22')
      end

      it 'defaults to a random server name' do
        expect(driver[:server_name]).to be_a(String)
      end

      it 'defaults to region id 1' do
        expect(driver[:region_id]).to eq('4')
      end

      it 'defaults to SSH Key Ids from $SSH_KEY_IDS' do
        expect(driver[:ssh_key_ids]).to eq('1234')
      end

      it 'defaults to Client ID from $DIGITALOCEAN_CLIENT_ID' do
        expect(driver[:digitalocean_client_id]).to eq('clientid')
      end

      it 'defaults to API key from $DIGITALOCEAN_API_KEY' do
        expect(driver[:digitalocean_api_key]).to eq('apikey')
      end
    end

    context 'name is ubuntu-12.10' do
      let(:platform_name) { 'ubuntu-12.10' }

      it 'defaults to the correct image ID' do
        expect(driver[:image_id]).to eq('3101891')
      end
    end

    context 'name is centos-6.4' do
      let(:platform_name) { 'centos-6.4' }

      it 'defaults to the correct image ID' do
        expect(driver[:image_id]).to eq('562354')
      end
    end

    context 'overridden options' do
      config = {
        :image_id => '22',
        :flavor_id => '63',
        :ssh_key_ids => '5678',
        :username => 'admin',
        :port => '2222',
        :server_name => 'puppy',
        :region_id => '1',
        :flavor => '1GB'
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
      double(:id => 'test123', :wait_for => true,
        :public_ip_address => '1.2.3.4')
    end
    let(:driver) do
      d = Kitchen::Driver::Digitalocean.new(config)
      d.instance = instance
      d.stub(:default_name).and_return('a_monkey!')
      d.stub(:create_server).and_return(server)
      d.stub(:wait_for_sshd).with('1.2.3.4').and_return(true)
      d
    end

    context 'username and API key only provided' do
      let(:config) do
        {
          :digitalocean_client_id => 'hello',
          :digitalocean_api_key => 'world'
        }
      end

      it 'generates a server name in the absence of one' do
        driver.create(state)
        expect(driver[:server_name]).to eq('a_monkey!')
      end

      it 'gets a proper server ID' do
        driver.create(state)
        expect(state[:server_id]).to eq('test123')
      end

      it 'gets a proper hostname (IP)' do
        driver.create(state)
        expect(state[:hostname]).to eq('1.2.3.4')
      end
    end
  end

  describe '#destroy' do
    let(:server_id) { '12345' }
    let(:hostname) { 'example.com' }
    let(:state) { { :server_id => server_id, :hostname => hostname } }
    let(:server) { double(:nil? => false, :destroy => true) }
    let(:servers) { double(:get => server) }
    let(:compute) { double(:servers => servers) }

    let(:driver) do
      d = Kitchen::Driver::Digitalocean.new(config)
      d.instance = instance
      d.stub(:compute).and_return(compute)
      d
    end

    context 'a live server that needs to be destroyed' do
      it 'destroys the server' do
        state.should_receive(:delete).with(:server_id)
        state.should_receive(:delete).with(:hostname)
        driver.destroy(state)
      end
    end

    context 'no server ID present' do
      let(:state) { Hash.new }

      it 'does nothing' do
        driver.stub(:compute)
        driver.should_not_receive(:compute)
        state.should_not_receive(:delete)
        driver.destroy(state)
      end
    end

    context 'a server that was already destroyed' do
      let(:servers) do
        s = double('servers')
        s.stub(:get).with('12345').and_return(nil)
        s
      end
      let(:compute) { double(:servers => servers) }
      let(:driver) do
        d = Kitchen::Driver::Digitalocean.new(config)
        d.instance = instance
        d.stub(:compute).and_return(compute)
        d
      end

      it 'does not try to destroy the server again' do
        allow_message_expectations_on_nil
        driver.destroy(state)
      end
    end
  end

  describe '#compute' do
    let(:config) do
      {
        :digitalocean_client_id => 'monkey',
        :digitalocean_api_key => 'potato',
      }
    end

    context 'all requirements provided' do
      it 'creates a new compute connection' do
        Fog::Compute.stub(:new) { |arg| arg }
        expect(driver.send(:compute)).to be_a(Hash)
      end
    end

    context 'no username provided' do
      let(:config) do
        { :digitalocean_client_id => nil, :digitalocean_api_key => '1234' }
      end

      it 'raises an error' do
        expect { driver.send(:compute) }.to raise_error(ArgumentError)
      end
    end

    context 'no API key provided' do
      let(:config) do
        { :digitalocean_client_id => 'monkey', :digitalocean_api_key => nil }
      end

      it 'raises an error' do
        expect { driver.send(:compute) }.to raise_error(ArgumentError)
      end
    end
  end

  describe '#create_server' do
    let(:config) do
      {
        :server_name => 'hello',
        :image_id => 'there',
        :flavor_id => '68',
        :region_id => '3',
        :private_networking => true,
        :ssh_key_ids => '1234'
      }
    end
    before(:each) do
      @expected = config.merge(:name => config[:server_name])
      @expected.delete_if do |k, v|
        k == :server_name
      end
    end
    let(:servers) do
      s = double('servers')
      s.stub(:create) { |arg| arg }
      s
    end
    let(:compute) { double(:servers => servers) }
    let(:driver) do
      d = Kitchen::Driver::Digitalocean.new(config)
      d.instance = instance
      d.stub(:compute).and_return(compute)
      d
    end

    it 'creates the server using a compute connection' do
      expect(driver.send(:create_server)).to eq(@expected)
    end
  end

  describe 'Region and Flavor names should be converted to IDs' do
    let(:config) do
      {
        :server_name => 'hello',
        :image_id => 'there',
        :flavor => '2gb',
        :region => 'amsterdam 2',
        :ssh_key_ids => '1234'
      }
    end

    it 'defaults to the correct flavor ID' do
      expect(driver[:flavor_id]).to eq('62')
    end

    it 'defaults to the correct region ID' do
      expect(driver[:region_id]).to eq('5')
    end
  end

  describe '#default_name' do
    before(:each) do
      Etc.stub(:getlogin).and_return('user')
      Socket.stub(:gethostname).and_return('host')
    end

    it 'generates a name' do
      expect(driver.default_name).to match(
        /^potatoes-user-(\S*)-host/)
    end
  end
end

# vim: ai et ts=2 sts=2 sw=2 ft=ruby
