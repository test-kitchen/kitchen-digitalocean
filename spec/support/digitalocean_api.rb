# frozen_string_literal: true

require "json"

# Builders and WebMock stubs for the slice of the DigitalOcean v2 API that the
# driver touches.
#
# Payloads are built in code rather than read from recorded fixture files so an
# example can describe exactly the state it cares about -- "a Droplet that is
# still booting and has no public address yet" -- in one readable line.
module DigitalOceanAPI
  # Environment variables the driver reads. Cleared before every example.
  MANAGED_ENV_VARS = %w{
    DIGITALOCEAN_ACCESS_TOKEN
    DIGITALOCEAN_API_URL
    DIGITALOCEAN_REGION
    DIGITALOCEAN_SSH_KEY_IDS
    SSH_KEY_IDS
  }.freeze

  API_ROOT = "https://api.digitalocean.com"

  JSON_HEADERS = { "Content-Type" => "application/json" }.freeze

  PUBLIC_NETWORK = {
    ip_address: "1.2.3.4",
    netmask: "255.255.240.0",
    gateway: "1.2.3.1",
    type: "public",
  }.freeze

  PRIVATE_NETWORK = {
    ip_address: "10.128.0.2",
    netmask: "255.255.0.0",
    gateway: "10.128.0.1",
    type: "private",
  }.freeze

  # Builds a Droplet payload as the API would return it.
  #
  # @param id [Integer, String] Droplet ID
  # @param status [String] one of "new", "active", "off", "archive"
  # @param networks [Symbol] :public, :private_only, :none or :absent
  # @param overrides [Hash] extra top level keys to merge in
  # @return [Hash] a Droplet payload
  def droplet_payload(id: 1234, status: "active", networks: :public, **overrides)
    payload = {
      id: id,
      name: "kitchen-test-droplet",
      memory: 1024,
      vcpus: 1,
      disk: 25,
      locked: false,
      status: status,
      created_at: "2026-01-01T00:00:00Z",
      features: %w{monitoring private_networking},
      backup_ids: [],
      snapshot_ids: [],
      image: {
        id: 155_500_000,
        name: "24.04 (LTS) x64",
        distribution: "Ubuntu",
        slug: "ubuntu-24-04-x64",
        public: true,
      },
      size_slug: "s-1vcpu-1gb",
      region: { name: "New York 1", slug: "nyc1", available: true },
      tags: [],
      vpc_uuid: nil,
    }

    payload[:networks] = networks_payload(networks) unless networks == :absent
    payload.merge(overrides)
  end

  # Builds the `networks` sub-document of a Droplet payload.
  #
  # @param kind [Symbol] :public, :private_only or :none
  # @return [Hash] a networks payload
  def networks_payload(kind)
    v4 = case kind
         when :public then [PRIVATE_NETWORK, PUBLIC_NETWORK]
         when :private_only then [PRIVATE_NETWORK]
         when :none then []
         else raise ArgumentError, "unknown networks kind: #{kind.inspect}"
         end

    { v4: v4, v6: [] }
  end

  # Builds a firewall payload as the API would return it.
  #
  # @param id [String] firewall ID
  # @param overrides [Hash] extra top level keys to merge in
  # @return [Hash] a firewall payload
  def firewall_payload(id: "fw-1", **overrides)
    {
      id: id,
      name: "kitchen-firewall",
      status: "succeeded",
      created_at: "2026-01-01T00:00:00Z",
      droplet_ids: [],
      tags: [],
      inbound_rules: [],
      outbound_rules: [],
    }.merge(overrides)
  end

  # Stubs `POST /v2/droplets`.
  #
  # @param droplet [Hash] the Droplet payload to return
  # @param status [Integer] HTTP status; 202 is what the real API returns
  # @return [WebMock::RequestStub] the registered stub
  def stub_droplet_create(droplet: droplet_payload(status: "new", networks: :none), status: 202)
    stub_request(:post, "#{API_ROOT}/v2/droplets")
      .to_return(status: status, body: { droplet: droplet }.to_json, headers: JSON_HEADERS)
  end

  # Stubs `GET /v2/droplets/:id`.
  #
  # Pass several payloads to describe a Droplet that changes between polls; the
  # last payload is repeated once the list is exhausted.
  #
  # @param id [Integer, String] Droplet ID
  # @param droplets [Array<Hash>] successive Droplet payloads to return
  # @return [WebMock::RequestStub] the registered stub
  def stub_droplet_find(id: 1234, droplets: [droplet_payload])
    responses = droplets.map do |droplet|
      { status: 200, body: { droplet: droplet }.to_json, headers: JSON_HEADERS }
    end

    stub_request(:get, "#{API_ROOT}/v2/droplets/#{id}").to_return(*responses)
  end

  # Stubs `GET /v2/droplets/:id` returning a 404.
  #
  # @param id [Integer, String] Droplet ID
  # @return [WebMock::RequestStub] the registered stub
  def stub_droplet_missing(id: 1234)
    stub_request(:get, "#{API_ROOT}/v2/droplets/#{id}")
      .to_return(status: 404, body: error_payload("not_found", "The resource you were accessing could not be found."),
                 headers: JSON_HEADERS)
  end

  # Stubs `DELETE /v2/droplets/:id`.
  #
  # @param id [Integer, String] Droplet ID
  # @param status [Integer] HTTP status; 204 is what the real API returns
  # @return [WebMock::RequestStub] the registered stub
  def stub_droplet_delete(id: 1234, status: 204)
    stub_request(:delete, "#{API_ROOT}/v2/droplets/#{id}").to_return(status: status)
  end

  # Stubs `GET /v2/firewalls/:id`.
  #
  # @param id [String] firewall ID
  # @param firewall [Hash] the firewall payload to return
  # @return [WebMock::RequestStub] the registered stub
  def stub_firewall_find(id: "fw-1", firewall: nil)
    firewall ||= firewall_payload(id: id)

    stub_request(:get, "#{API_ROOT}/v2/firewalls/#{id}")
      .to_return(status: 200, body: { firewall: firewall }.to_json, headers: JSON_HEADERS)
  end

  # Stubs `GET /v2/firewalls/:id` returning a 404.
  #
  # @param id [String] firewall ID
  # @return [WebMock::RequestStub] the registered stub
  def stub_firewall_missing(id: "fw-1")
    stub_request(:get, "#{API_ROOT}/v2/firewalls/#{id}")
      .to_return(status: 404, body: error_payload("not_found", "The resource you were accessing could not be found."),
                 headers: JSON_HEADERS)
  end

  # Stubs `POST /v2/firewalls/:id/droplets`.
  #
  # @param id [String] firewall ID
  # @return [WebMock::RequestStub] the registered stub
  def stub_firewall_add_droplets(id: "fw-1")
    stub_request(:post, "#{API_ROOT}/v2/firewalls/#{id}/droplets").to_return(status: 204)
  end

  # Builds a DigitalOcean error body.
  #
  # @param id [String] machine readable error ID
  # @param message [String] human readable message
  # @return [String] a JSON error body
  def error_payload(id, message)
    { id: id, message: message }.to_json
  end

  # Parses the JSON body of a recorded WebMock request.
  #
  # @param request [WebMock::RequestSignature] the recorded request
  # @return [Hash] the parsed body, with symbol keys
  def request_body(request)
    JSON.parse(request.body, symbolize_names: true)
  end
end
