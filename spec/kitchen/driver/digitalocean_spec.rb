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

require "spec_helper"

RSpec.describe Kitchen::Driver::Digitalocean do
  subject(:driver) { build_driver }

  let(:state) { {} }

  describe "plugin contract" do
    it "is a Test Kitchen driver" do
      expect(described_class.ancestors).to include(Kitchen::Driver::Base)
    end

    it "reports a display name Test Kitchen can use" do
      expect(driver.name).to eq("Digitalocean")
    end

    it "is registered under the name used in kitchen.yml" do
      expect(Kitchen::Driver.const_get(:Digitalocean)).to eq(described_class)
    end
  end

  describe "plugin metadata" do
    it "declares the driver API version" do
      expect(described_class.instance_variable_get(:@api_version)).to eq(2)
    end

    it "reports its own gem version to kitchen diagnose" do
      expect(driver.diagnose_plugin[:version])
        .to eq(Kitchen::Driver::DIGITALOCEAN_VERSION)
    end
  end

  describe "#status" do
    let(:droplet) { instance_double(DropletKit::Droplet, status: "active") }

    it "reports an unknown status with no droplet in state" do
      expect(driver.status({})).to include(live: nil, state: "unknown")
    end

    it "reports an unknown status when the droplet is gone" do
      allow(driver).to receive(:find_droplet).with(42).and_return(nil)

      expect(driver.status(server_id: 42)).to include(state: "unknown")
    end

    it "reports a running droplet as live" do
      allow(driver).to receive(:find_droplet).with(42).and_return(droplet)

      expect(driver.status(server_id: 42)).to include(
        live: true, state: "active", source: "driver", resource_id: "42"
      )
    end

    it "reports a powered off droplet as not live" do
      allow(driver).to receive(:find_droplet)
        .and_return(instance_double(DropletKit::Droplet, status: "off"))

      expect(driver.status(server_id: 42)).to include(live: false, state: "off")
    end

    it "stamps when the check happened" do
      allow(driver).to receive(:find_droplet).and_return(droplet)

      expect(driver.status(server_id: 42)[:checked_at])
        .to match(/\A\d{4}-\d{2}-\d{2}T/)
    end

    it "reports an unknown status when the API cannot be reached" do
      allow(driver).to receive(:find_droplet)
        .and_raise(Kitchen::ActionFailed.new("boom"))

      expect(driver.status(server_id: 42)).to include(state: "unknown")
    end
  end

  describe "#doctor" do
    before do
      allow(driver).to receive(:client)
        .and_return(double(account: double(info: true)))
    end

    it "reports no problem when the configuration is complete" do
      expect(driver.doctor(state)).to be(false)
    end

    it "reports an empty ssh_key_ids" do
      d = build_driver(ssh_key_ids: [])
      allow(d).to receive(:client)
        .and_return(double(account: double(info: true)))

      expect(d.doctor(state)).to be(true)
      expect(logged_output.string).to match(/ssh_key_ids is set but empty/)
    end

    it "reports a token DigitalOcean rejects" do
      allow(driver).to receive(:client).and_raise(StandardError.new("401"))

      expect(driver.doctor(state)).to be(true)
      expect(logged_output.string).to match(/rejected the configured access token/)
    end
  end

  describe "configuration defaults" do
    {
      username: "root",
      port: "22",
      size: "s-1vcpu-1gb",
      monitoring: false,
      private_networking: true,
      ipv6: false,
      user_data: nil,
      tags: nil,
      firewalls: nil,
      vpcs: nil,
      api_url: "https://api.digitalocean.com",
      region: "nyc1",
    }.each do |key, value|
      it "defaults #{key} to #{value.inspect}" do
        expect(build_driver({})[key]).to eq(value)
      end
    end

    it "defaults the server name to a generated name" do
      expect(build_driver({})[:server_name]).to match(/\Adefaultubuntu24-/)
    end

    it "defaults the image to the slug for the instance platform" do
      expect(build_driver({})[:image]).to eq("ubuntu-24-04-x64")
    end

    it "polls on an interval that leaves room for a Droplet to boot" do
      driver = Kitchen::Driver::Digitalocean.new(
        digitalocean_access_token: "t", ssh_key_ids: "1"
      ).finalize_config!(kitchen_instance)

      expect(driver[:server_wait_interval]).to eq(8)
      expect(driver[:server_wait_timeout]).to eq(600)
    end

    describe "overrides" do
      overrides = {
        image: "debian-13-x64",
        size: "s-2vcpu-4gb",
        ssh_key_ids: "5678",
        username: "admin",
        port: "2222",
        server_name: "puppy",
        region: "ams3",
        monitoring: true,
        ipv6: true,
        user_data: "#cloud-config\n",
        tags: %w{web db},
        vpcs: "3a92ae2d-f1b7-4589-81b8-8ef144374453",
        api_url: "https://api.example.test",
        server_wait_interval: 1,
        server_wait_timeout: 30,
      }

      overrides.each do |key, value|
        it "honours an explicit #{key}" do
          expect(build_driver(overrides)[key]).to eq(value)
        end
      end
    end
  end

  describe "configuration from the environment" do
    it "reads the access token from DIGITALOCEAN_ACCESS_TOKEN" do
      ENV["DIGITALOCEAN_ACCESS_TOKEN"] = "env-token"
      ENV["DIGITALOCEAN_SSH_KEY_IDS"] = "1"

      expect(build_driver_without_defaults[:digitalocean_access_token]).to eq("env-token")
    end

    it "reads SSH key IDs from DIGITALOCEAN_SSH_KEY_IDS" do
      ENV["DIGITALOCEAN_ACCESS_TOKEN"] = "t"
      ENV["DIGITALOCEAN_SSH_KEY_IDS"] = "env-keys"

      expect(build_driver_without_defaults[:ssh_key_ids]).to eq("env-keys")
    end

    it "falls back to SSH_KEY_IDS when DIGITALOCEAN_SSH_KEY_IDS is unset" do
      ENV["DIGITALOCEAN_ACCESS_TOKEN"] = "t"
      ENV["SSH_KEY_IDS"] = "legacy-keys"

      expect(build_driver_without_defaults[:ssh_key_ids]).to eq("legacy-keys")
    end

    it "prefers DIGITALOCEAN_SSH_KEY_IDS over SSH_KEY_IDS" do
      ENV["DIGITALOCEAN_ACCESS_TOKEN"] = "t"
      ENV["DIGITALOCEAN_SSH_KEY_IDS"] = "preferred"
      ENV["SSH_KEY_IDS"] = "legacy"

      expect(build_driver_without_defaults[:ssh_key_ids]).to eq("preferred")
    end

    it "reads the region from DIGITALOCEAN_REGION" do
      ENV["DIGITALOCEAN_REGION"] = "tor1"

      expect(build_driver({})[:region]).to eq("tor1")
    end

    it "reads the API URL from DIGITALOCEAN_API_URL" do
      ENV["DIGITALOCEAN_API_URL"] = "https://api.example.test"

      expect(build_driver({})[:api_url]).to eq("https://api.example.test")
    end

    it "prefers explicit configuration over the environment" do
      ENV["DIGITALOCEAN_REGION"] = "tor1"

      expect(build_driver(region: "lon1")[:region]).to eq("lon1")
    end
  end

  describe "required configuration" do
    it "rejects a missing access token" do
      expect { build_driver_without_defaults }
        .to raise_error(Kitchen::UserError, /digitalocean_access_token/)
    end

    it "rejects a missing ssh_key_ids" do
      ENV["DIGITALOCEAN_ACCESS_TOKEN"] = "t"

      expect { build_driver_without_defaults }
        .to raise_error(Kitchen::UserError, /ssh_key_ids/)
    end
  end

  describe "#default_image" do
    described_class::PLATFORM_SLUG_MAP.each do |platform, slug|
      it "maps the #{platform} platform to #{slug}" do
        driver = build_driver({}, kitchen_instance(platform: platform))

        expect(driver.default_image).to eq(slug)
      end
    end

    it "passes an unmapped platform name straight through as a slug" do
      driver = build_driver({}, kitchen_instance(platform: "ubuntu-24-04-x64"))

      expect(driver.default_image).to eq("ubuntu-24-04-x64")
    end

    it "passes a private image ID straight through" do
      driver = build_driver({}, kitchen_instance(platform: "123456789"))

      expect(driver.default_image).to eq("123456789")
    end

    describe "PLATFORM_SLUG_MAP" do
      it "is frozen" do
        expect(described_class::PLATFORM_SLUG_MAP).to be_frozen
      end

      it "only maps onto x64 slugs" do
        expect(described_class::PLATFORM_SLUG_MAP.values).to all(include("x64"))
      end

      it "has no duplicate slugs" do
        slugs = described_class::PLATFORM_SLUG_MAP.values

        expect(slugs.uniq.length).to eq(slugs.length)
      end
    end
  end

  describe "#default_name" do
    before do
      allow(Etc).to receive(:getlogin).and_return("user")
      allow(Socket).to receive(:gethostname).and_return("host")
    end

    it "joins the instance name, login, hostname and a random suffix" do
      driver = build_driver({}, kitchen_instance(name: "potatoes"))

      expect(driver.default_name).to match(/\Apotatoes-user-host-[a-z0-9]{7}\z/)
    end

    it "is different on every call" do
      driver = build_driver({})

      expect(driver.default_name).not_to eq(driver.default_name)
    end

    it "falls back to a placeholder when there is no login name" do
      allow(Etc).to receive(:getlogin).and_return(nil)
      driver = build_driver({}, kitchen_instance(name: "potatoes"))

      expect(driver.default_name).to match(/\Apotatoes-nologin-host-/)
    end

    context "with a long hostname" do
      before { allow(Socket).to receive(:gethostname).and_return("ab.c" * 20) }

      it "stays within the 63 character DNS label limit" do
        expect(build_driver({}).default_name.length).to be <= described_class::MAX_SERVER_NAME_LENGTH
      end
    end

    context "with a long hostname, login and instance name" do
      before do
        allow(Etc).to receive(:getlogin).and_return("abcd" * 20)
        allow(Socket).to receive(:gethostname).and_return("efgh" * 20)
      end

      it "uses the full 63 character budget" do
        driver = build_driver({}, kitchen_instance(name: "ijkl" * 20))

        expect(driver.default_name.length).to eq(described_class::MAX_SERVER_NAME_LENGTH)
      end
    end

    context "with punctuation in the login, hostname and instance name" do
      before do
        allow(Etc).to receive(:getlogin).and_return("some.u-se-r")
        allow(Socket).to receive(:gethostname).and_return("a.host-name")
      end

      subject(:name) do
        build_driver({}, kitchen_instance(name: "a.instance-name")).default_name
      end

      it "strips dots, which DigitalOcean rejects in Droplet names" do
        expect(name).not_to include(".")
      end

      it "keeps only the three separators" do
        expect(name.count("-")).to eq(3)
      end
    end

    it "turns underscores into hyphens, which DigitalOcean does accept" do
      driver = build_driver({}, kitchen_instance(name: "my_suite_name"))

      expect(driver.default_name).to start_with("my-suite-name-")
    end
  end

  describe "#create" do
    before do
      stub_droplet_create
      stub_droplet_find(droplets: [droplet_payload])
    end

    it "records the Droplet ID in state" do
      driver.create(state)

      expect(state[:server_id]).to eq(1234)
    end

    it "records the public IPv4 address as the hostname" do
      driver.create(state)

      expect(state[:hostname]).to eq("1.2.3.4")
    end

    it "ignores the private address when picking a hostname" do
      driver.create(state)

      expect(state[:hostname]).not_to eq(DigitalOceanAPI::PRIVATE_NETWORK[:ip_address])
    end

    it "records the SSH username and port in state" do
      build_driver(username: "admin", port: "2222").create(state)

      expect(state).to include(username: "admin", port: "2222")
    end

    it "waits for the SSH transport to answer" do
      expect(transport_connection).to receive(:wait_until_ready)

      driver.create(state)
    end

    it "hands the populated state to the transport" do
      expect(transport).to receive(:connection)
        .with(hash_including(hostname: "1.2.3.4", username: "root", port: "22"))

      driver.create(state)
    end

    it "logs that the instance was created" do
      driver.create(state)

      expect(log_output).to include("DigitalOcean instance <1234> created.")
    end

    describe "waiting for a public address" do
      it "polls until the Droplet reports a public IPv4 address" do
        stub_droplet_find(droplets: [
          droplet_payload(status: "new", networks: :none),
          droplet_payload(status: "active", networks: :private_only),
          droplet_payload(status: "active", networks: :public),
        ])

        driver.create(state)

        expect(a_request(:get, "#{DigitalOceanAPI::API_ROOT}/v2/droplets/1234")).to have_been_made.times(3)
      end

      it "does not re-fetch the Droplet once it has an address" do
        driver.create(state)

        expect(a_request(:get, "#{DigitalOceanAPI::API_ROOT}/v2/droplets/1234")).to have_been_made.once
      end

      it "tolerates a Droplet payload with no networks key at all" do
        stub_droplet_find(droplets: [
          droplet_payload(status: "new", networks: :absent),
          droplet_payload(status: "active", networks: :public),
        ])

        expect { driver.create(state) }.not_to raise_error
      end

      it "gives up once the timeout elapses" do
        stub_droplet_find(droplets: [droplet_payload(status: "new", networks: :none)])
        driver = build_driver(server_wait_timeout: 0)

        expect { driver.create(state) }
          .to raise_error(Kitchen::ActionFailed, /Timed out after 0 seconds waiting for/)
      end

      it "leaves the Droplet ID in state when it times out, so destroy can clean up" do
        stub_droplet_find(droplets: [droplet_payload(status: "new", networks: :none)])
        driver = build_driver(server_wait_timeout: 0)

        expect { driver.create(state) }.to raise_error(Kitchen::ActionFailed)
        expect(state[:server_id]).to eq(1234)
      end
    end

    describe "when the instance already exists" do
      let(:state) { { server_id: 1234, hostname: "1.2.3.4" } }

      it "does not create a second Droplet" do
        driver.create(state)

        expect(a_request(:post, "#{DigitalOceanAPI::API_ROOT}/v2/droplets")).not_to have_been_made
      end

      it "says so in the log" do
        driver.create(state)

        expect(log_output).to include("DigitalOcean instance <1234> already created.")
      end
    end

    describe "pre_create_command" do
      it "runs the configured command before provisioning" do
        driver = build_driver(pre_create_command: "echo hello")
        expect(driver).to receive(:run_command).with("echo hello")

        driver.create(state)
      end

      it "turns a failing command into an ActionFailed" do
        driver = build_driver(pre_create_command: "false")
        allow(driver).to receive(:run_command).and_raise(Kitchen::ShellOut::ShellCommandFailed, "boom")

        expect { driver.create(state) }.to raise_error(Kitchen::ActionFailed, /pre_create_command/)
      end
    end

    describe "when the API rejects the request" do
      it "raises a Test Kitchen error rather than leaking a droplet_kit backtrace" do
        stub_request(:post, "#{DigitalOceanAPI::API_ROOT}/v2/droplets")
          .to_return(status: 401, body: error_payload("unauthorized", "Unable to authenticate you."),
                     headers: DigitalOceanAPI::JSON_HEADERS)

        expect { driver.create(state) }
          .to raise_error(Kitchen::ActionFailed, /401.*Unable to authenticate you/m)
      end

      it "does not record a server ID" do
        stub_request(:post, "#{DigitalOceanAPI::API_ROOT}/v2/droplets")
          .to_return(status: 422, body: error_payload("unprocessable_entity", "invalid size"),
                     headers: DigitalOceanAPI::JSON_HEADERS)

        expect { driver.create(state) }.to raise_error(Kitchen::ActionFailed)
        expect(state).to be_empty
      end

      it "raises a clear error when the API returns an unexpected success status" do
        stub_droplet_create(status: 200)

        expect { driver.create(state) }
          .to raise_error(Kitchen::ActionFailed, /unexpected response.*access token/m)
      end

      it "raises a Test Kitchen error when the Droplet lookup fails" do
        stub_request(:get, "#{DigitalOceanAPI::API_ROOT}/v2/droplets/1234")
          .to_return(status: 500, body: error_payload("server_error", "oops"),
                     headers: DigitalOceanAPI::JSON_HEADERS)

        expect { driver.create(state) }.to raise_error(Kitchen::ActionFailed, /500/)
      end
    end
  end

  describe "the Droplet create request" do
    subject(:body) do
      driver.create(state)
      request_body(created_droplet_request)
    end

    before do
      stub_droplet_create
      stub_droplet_find(droplets: [droplet_payload])
    end

    it "sends the configured server name" do
      driver = build_driver(server_name: "hello")
      driver.create(state)

      expect(request_body(created_droplet_request)).to include(name: "hello")
    end

    it "sends the region, image and size" do
      driver = build_driver(region: "nyc3", image: "debian-13-x64", size: "s-2vcpu-4gb")
      driver.create(state)

      expect(request_body(created_droplet_request))
        .to include(region: "nyc3", image: "debian-13-x64", size: "s-2vcpu-4gb")
    end

    it "sends the monitoring, ipv6 and private networking flags" do
      driver = build_driver(monitoring: true, ipv6: true, private_networking: false)
      driver.create(state)

      expect(request_body(created_droplet_request))
        .to include(monitoring: true, ipv6: true, private_networking: false)
    end

    it "sends user data verbatim" do
      driver = build_driver(user_data: "#cloud-config\npackages: [git]\n")
      driver.create(state)

      expect(request_body(created_droplet_request)).to include(user_data: "#cloud-config\npackages: [git]\n")
    end

    it "sends the VPC UUID" do
      driver = build_driver(vpcs: "3a92ae2d-f1b7-4589-81b8-8ef144374453")
      driver.create(state)

      expect(request_body(created_droplet_request))
        .to include(vpc_uuid: "3a92ae2d-f1b7-4589-81b8-8ef144374453")
    end

    describe "ssh_keys" do
      {
        "a single ID" => ["1234", %w{1234}],
        "a comma separated list" => ["1234,5678", %w{1234 5678}],
        "a comma and space separated list" => ["1234, 5678", %w{1234 5678}],
        "a space separated list" => ["1234 5678", %w{1234 5678}],
        "a YAML array" => [%w{1234 5678}, %w{1234 5678}],
        "an array of integers" => [[1234, 5678], %w{1234 5678}],
        "a bare integer" => [1234, %w{1234}],
        "a fingerprint" => ["aa:bb:cc", %w{aa:bb:cc}],
      }.each do |description, (configured, expected)|
        it "sends #{description} as #{expected.inspect}" do
          build_driver(ssh_key_ids: configured).create(state)

          expect(request_body(created_droplet_request)).to include(ssh_keys: expected)
        end
      end
    end

    describe "tags" do
      {
        "a single tag" => ["web", %w{web}],
        "a comma separated list" => ["web,db", %w{web db}],
        "a comma and space separated list" => ["web, db", %w{web db}],
        "a space separated list" => ["web db", %w{web db}],
        "a YAML array" => [%w{web db}, %w{web db}],
        "no tags" => [nil, []],
      }.each do |description, (configured, expected)|
        it "sends #{description} as #{expected.inspect}" do
          build_driver(tags: configured).create(state)

          expect(request_body(created_droplet_request)).to include(tags: expected)
        end
      end
    end

    def created_droplet_request
      request = nil
      WebMock::RequestRegistry.instance.requested_signatures.each do |signature, _count|
        request = signature if signature.method == :post && signature.uri.path == "/v2/droplets"
      end
      request
    end
  end

  describe "firewalls" do
    before do
      stub_droplet_create
      stub_droplet_find(droplets: [droplet_payload])
    end

    it "makes no firewall calls when none are configured" do
      driver.create(state)

      expect(WebMock).not_to have_requested(:get, %r{/v2/firewalls/})
    end

    it "attaches the Droplet to a firewall given by ID" do
      stub_firewall_find(id: "fw-1")
      stub_firewall_add_droplets(id: "fw-1")

      build_driver(firewalls: "fw-1").create(state)

      expect(WebMock).to have_requested(:post, "#{DigitalOceanAPI::API_ROOT}/v2/firewalls/fw-1/droplets")
        .with(body: { droplet_ids: [1234] }.to_json)
    end

    %w{fw-1,fw-2 fw-1,\ fw-2}.each do |configured|
      it "attaches to every firewall in #{configured.inspect}" do
        %w{fw-1 fw-2}.each do |id|
          stub_firewall_find(id: id)
          stub_firewall_add_droplets(id: id)
        end

        build_driver(firewalls: configured).create(state)

        %w{fw-1 fw-2}.each do |id|
          expect(WebMock).to have_requested(:post, "#{DigitalOceanAPI::API_ROOT}/v2/firewalls/#{id}/droplets")
        end
      end
    end

    it "accepts a YAML array of firewall IDs" do
      %w{fw-1 fw-2}.each do |id|
        stub_firewall_find(id: id)
        stub_firewall_add_droplets(id: id)
      end

      build_driver(firewalls: %w{fw-1 fw-2}).create(state)

      expect(WebMock).to have_requested(:post, "#{DigitalOceanAPI::API_ROOT}/v2/firewalls/fw-2/droplets")
    end

    it "warns and carries on when a firewall does not exist" do
      stub_firewall_missing(id: "nope")

      build_driver(firewalls: "nope").create(state)

      expect(log_output).to include("firewalls id: 'nope' was not found in api, ignoring")
      expect(state[:hostname]).to eq("1.2.3.4")
    end

    it "warns and carries on when the firewalls setting is not a list" do
      build_driver(firewalls: { id: "fw-1" }).create(state)

      expect(log_output).to include("firewalls attribute is not a String or Array, ignoring")
      expect(state[:hostname]).to eq("1.2.3.4")
    end

    it "raises a Test Kitchen error when attaching the firewall fails" do
      stub_firewall_find(id: "fw-1")
      stub_request(:post, "#{DigitalOceanAPI::API_ROOT}/v2/firewalls/fw-1/droplets")
        .to_return(status: 422, body: error_payload("unprocessable_entity", "nope"),
                   headers: DigitalOceanAPI::JSON_HEADERS)

      expect { build_driver(firewalls: "fw-1").create(state) }
        .to raise_error(Kitchen::ActionFailed, /422/)
    end
  end

  describe "#destroy" do
    let(:state) { { server_id: 1234, hostname: "1.2.3.4" } }

    it "does nothing without a server ID" do
      driver.destroy({})

      expect(WebMock).not_to have_requested(:any, %r{api\.digitalocean\.com})
    end

    it "deletes an active Droplet" do
      stub_droplet_find(droplets: [droplet_payload(status: "active")])
      stub_droplet_delete

      driver.destroy(state)

      expect(WebMock).to have_requested(:delete, "#{DigitalOceanAPI::API_ROOT}/v2/droplets/1234")
    end

    it "clears the server ID and hostname from state" do
      stub_droplet_find(droplets: [droplet_payload(status: "active")])
      stub_droplet_delete

      driver.destroy(state)

      expect(state).to be_empty
    end

    it "logs the destruction" do
      stub_droplet_find(droplets: [droplet_payload(status: "active")])
      stub_droplet_delete

      driver.destroy(state)

      expect(log_output).to include("DigitalOcean instance <1234> destroyed.")
    end

    it "waits for a Droplet that is still in the new status" do
      stub_droplet_find(droplets: [
        droplet_payload(status: "new"),
        droplet_payload(status: "new"),
        droplet_payload(status: "active"),
      ])
      stub_droplet_delete

      driver.destroy(state)

      expect(a_request(:get, "#{DigitalOceanAPI::API_ROOT}/v2/droplets/1234")).to have_been_made.times(3)
      expect(WebMock).to have_requested(:delete, "#{DigitalOceanAPI::API_ROOT}/v2/droplets/1234")
    end

    it "gives up on a Droplet that never leaves the new status" do
      stub_droplet_find(droplets: [droplet_payload(status: "new")])
      driver = build_driver(server_wait_timeout: 0)

      expect { driver.destroy(state) }
        .to raise_error(Kitchen::ActionFailed, /Timed out .* waiting for .* to become active/)
    end

    it "keeps the state intact when it gives up, so destroy can be retried" do
      stub_droplet_find(droplets: [droplet_payload(status: "new")])
      driver = build_driver(server_wait_timeout: 0)

      expect { driver.destroy(state) }.to raise_error(Kitchen::ActionFailed)
      expect(state[:server_id]).to eq(1234)
    end

    describe "when the Droplet is already gone" do
      before { stub_droplet_missing }

      it "does not attempt a delete" do
        driver.destroy(state)

        expect(WebMock).not_to have_requested(:delete, "#{DigitalOceanAPI::API_ROOT}/v2/droplets/1234")
      end

      it "still clears the state" do
        driver.destroy(state)

        expect(state).to be_empty
      end

      it "says so in the log" do
        driver.destroy(state)

        expect(log_output).to include("DigitalOcean instance <1234> is already gone.")
      end
    end

    it "raises a Test Kitchen error when the lookup fails for another reason" do
      stub_request(:get, "#{DigitalOceanAPI::API_ROOT}/v2/droplets/1234")
        .to_return(status: 401, body: error_payload("unauthorized", "Unable to authenticate you."),
                   headers: DigitalOceanAPI::JSON_HEADERS)

      expect { driver.destroy(state) }.to raise_error(Kitchen::ActionFailed, /401/)
    end

    it "raises a Test Kitchen error when the delete fails" do
      stub_droplet_find(droplets: [droplet_payload(status: "active")])
      stub_request(:delete, "#{DigitalOceanAPI::API_ROOT}/v2/droplets/1234")
        .to_return(status: 403, body: error_payload("forbidden", "nope"),
                   headers: DigitalOceanAPI::JSON_HEADERS)

      expect { driver.destroy(state) }.to raise_error(Kitchen::ActionFailed, /403/)
      expect(state[:server_id]).to eq(1234)
    end
  end

  describe "the API client" do
    it "is built once and reused across calls" do
      expect(DropletKit::Client).to receive(:new).once.and_call_original

      stub_droplet_create
      stub_droplet_find(droplets: [droplet_payload])
      driver.create(state)
    end

    it "is pointed at the configured API URL" do
      stub_request(:post, "https://api.example.test/v2/droplets")
        .to_return(status: 202, body: { droplet: droplet_payload }.to_json,
                   headers: DigitalOceanAPI::JSON_HEADERS)
      stub_request(:get, "https://api.example.test/v2/droplets/1234")
        .to_return(status: 200, body: { droplet: droplet_payload }.to_json,
                   headers: DigitalOceanAPI::JSON_HEADERS)

      build_driver(api_url: "https://api.example.test").create(state)

      expect(WebMock).to have_requested(:post, "https://api.example.test/v2/droplets")
    end

    it "authenticates with the configured access token" do
      stub_droplet_create
      stub_droplet_find(droplets: [droplet_payload])

      build_driver(digitalocean_access_token: "secret-token").create(state)

      expect(WebMock).to have_requested(:post, "#{DigitalOceanAPI::API_ROOT}/v2/droplets")
        .with(headers: { "Authorization" => "Bearer secret-token" })
    end

    describe "debug logging" do
      before do
        stub_droplet_create
        stub_droplet_find(droplets: [droplet_payload])
      end

      it "never writes the access token to the log" do
        build_driver(digitalocean_access_token: "super-secret-token").create(state)

        expect(log_output).not_to include("super-secret-token")
      end

      it "logs a redacted token so the right account can still be identified" do
        build_driver(digitalocean_access_token: "super-secret-token").create(state)

        expect(log_output).to match(/digitalocean:access_token \*+oken/)
      end

      it "does not blow up when the token is short" do
        build_driver(digitalocean_access_token: "abc").create(state)

        expect(log_output).to include("digitalocean:access_token ***")
      end

      it "logs the resolved Droplet configuration" do
        build_driver(size: "s-2vcpu-4gb").create(state)

        expect(log_output).to include("digitalocean:size s-2vcpu-4gb")
      end

      it "puts a space between the image label and its value" do
        build_driver(image: "debian-13-x64").create(state)

        expect(log_output).to include("digitalocean:image debian-13-x64")
      end
    end
  end

  describe "#normalize_list" do
    subject(:normalize) { ->(value) { driver.send(:normalize_list, value) } }

    it "treats nil as an empty list" do
      expect(normalize.call(nil)).to eq([])
    end

    it "splits on commas" do
      expect(normalize.call("a,b,c")).to eq(%w{a b c})
    end

    it "splits on commas with surrounding whitespace" do
      expect(normalize.call("a , b ,c")).to eq(%w{a b c})
    end

    it "splits on whitespace" do
      expect(normalize.call("a b\tc")).to eq(%w{a b c})
    end

    it "drops empty entries produced by trailing separators" do
      expect(normalize.call("a,,b,")).to eq(%w{a b})
    end

    it "ignores leading and trailing whitespace" do
      expect(normalize.call("  a, b  ")).to eq(%w{a b})
    end

    it "stringifies array members" do
      expect(normalize.call([1, :two, "three"])).to eq(%w{1 two three})
    end

    it "drops blank array members" do
      expect(normalize.call(["a", "", "  "])).to eq(%w{a})
    end

    it "wraps a bare number" do
      expect(normalize.call(42)).to eq(%w{42})
    end

    it "returns nil for a type that cannot be read as a list" do
      expect(normalize.call({ a: 1 })).to be_nil
    end
  end

  # Builds a driver with no configuration of its own, so the `default_config`
  # blocks that read ENV are the only source of values.
  def build_driver_without_defaults
    Kitchen::Driver::Digitalocean.new({}).finalize_config!(kitchen_instance)
  end
end
