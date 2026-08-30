# kitchen-digitalocean

[![Gem Version](https://badge.fury.io/rb/kitchen-digitalocean.svg)](https://badge.fury.io/rb/kitchen-digitalocean)

A [Test Kitchen](https://kitchen.ci) driver that runs your test suites on real
[DigitalOcean](https://www.digitalocean.com) Droplets.

Test Kitchen builds a throwaway machine, converges your cookbook or configuration
on it, runs your tests, and destroys the machine. This driver is the piece that
knows how to talk to DigitalOcean: it creates a Droplet, waits until SSH answers,
hands the address back to Test Kitchen, and deletes the Droplet when you are done.

Droplets cost money for as long as they exist. Always finish with
`cinc kitchen destroy`, and see [Cleaning up](#cleaning-up) if a run is interrupted.

> This documentation uses [Cinc Workstation](https://cinc.sh/) and the `cinc` commands throughout. Everything here
> works identically with Chef Workstation — see [Using with Chef](#using-with-chef).

## Before you start

You need three things:

* A DigitalOcean account.
* A **personal access token** with read and write scope.
* An **SSH key** uploaded to DigitalOcean, and the ID or fingerprint of that key.

### Get an access token

Go to **API → Tokens** in the [DigitalOcean control panel](https://cloud.digitalocean.com/account/api/tokens)
and generate a new token with write scope. Copy it now — the control panel will
not show it again.

### Upload an SSH key and find its ID

Add your public key under **Settings → Security → SSH keys**, then look up its ID.
With [`doctl`](https://docs.digitalocean.com/reference/doctl/):

```bash
doctl compute ssh-key list
```

Or straight from the API:

```bash
curl -sH "Authorization: Bearer $DIGITALOCEAN_ACCESS_TOKEN" \
  "https://api.digitalocean.com/v2/account/keys"
```

Either the numeric `id` or the key `fingerprint` works.

The driver installs this key on the Droplet as the `root` user's authorized key.
Test Kitchen connects with the matching private key from your SSH agent, so make
sure the key is loaded — check with `ssh-add -l`.

## Installation

If you use [Cinc Workstation](https://cinc.sh/start/workstation/), this driver is
already bundled and you can skip ahead.

Otherwise install the gem:

```bash
gem install kitchen-digitalocean
```

Or add it to your project's `Gemfile`:

```ruby
source "https://rubygems.org"

gem "test-kitchen"
gem "kitchen-digitalocean"
```

## Quick start

Export your credentials. The driver reads both from the environment, which keeps
secrets out of the `kitchen.yml` you commit:

```bash
export DIGITALOCEAN_ACCESS_TOKEN="dop_v1_..."
export DIGITALOCEAN_SSH_KEY_IDS="12345678"
```

Create a `kitchen.yml` in the root of your project:

```yaml
---
driver:
  name: digitalocean
  region: nyc1
  size: s-1vcpu-1gb

provisioner:
  name: cinc_infra

platforms:
  - name: ubuntu-24
  - name: debian-13

suites:
  - name: default
    run_list:
      - recipe[my_cookbook::default]
```

Then run it:

```bash
cinc kitchen test
```

That creates a Droplet per platform, converges it, verifies it, and destroys it.
While you are iterating, the individual steps are more useful:

```bash
cinc kitchen list         # what instances exist and what state they are in
cinc kitchen create       # build the Droplet only
cinc kitchen converge     # apply your configuration
cinc kitchen login        # SSH into the running Droplet
cinc kitchen destroy      # delete the Droplet
```

## Configuration

Every setting goes under the `driver` key in `kitchen.yml`, and can be overridden
per platform or per suite.

| Setting | Default | Description |
| --- | --- | --- |
| `digitalocean_access_token` | `$DIGITALOCEAN_ACCESS_TOKEN` | **Required.** API token with write scope. |
| `ssh_key_ids` | `$DIGITALOCEAN_SSH_KEY_IDS`, then `$SSH_KEY_IDS` | **Required.** One or more SSH key IDs or fingerprints. |
| `region` | `$DIGITALOCEAN_REGION`, else `nyc1` | Datacenter region slug, e.g. `nyc3`, `lon1`, `sfo3`. |
| `size` | `s-1vcpu-1gb` | Droplet size slug. |
| `image` | derived from the platform name | Image slug or private image ID. |
| `server_name` | generated | Droplet name. Generated names are unique per instance, user and workstation. |
| `username` | `root` | SSH user Test Kitchen connects as. |
| `port` | `22` | SSH port. |
| `monitoring` | `false` | Install the DigitalOcean metrics agent. |
| `ipv6` | `false` | Enable IPv6 networking. |
| `private_networking` | `true` | Enable legacy private networking. Prefer `vpcs`. |
| `vpcs` | none | UUID of the VPC to place the Droplet in. A list is accepted, but DigitalOcean places a Droplet in one VPC, so only the first is used. |
| `tags` | none | Tags to apply. String or list. |
| `firewalls` | none | Cloud firewall IDs to attach the Droplet to. String or list. |
| `user_data` | none | Cloud-init user data, run on first boot. |
| `api_url` | `$DIGITALOCEAN_API_URL`, else `https://api.digitalocean.com` | API endpoint. Useful for testing against a proxy. |
| `server_wait_interval` | `8` | Seconds between API polls while waiting on a Droplet. |
| `server_wait_timeout` | `600` | Seconds to wait before giving up on a Droplet. |

`ssh_key_ids`, `tags` and `firewalls` all accept either a delimited string or a
YAML list, so both of these mean the same thing:

```yaml
driver:
  tags: web,staging
```

```yaml
driver:
  tags:
    - web
    - staging
```

### Platforms and images

The platform name is what picks the image. Short names are translated to the
matching DigitalOcean slug:

| Platform name | Image slug |
| --- | --- |
| `almalinux-8` | `almalinux-8-x64` |
| `almalinux-9` | `almalinux-9-x64` |
| `centos-7` | `centos-7-x64` |
| `centos-8` | `centos-8-x64` |
| `centos-stream-9` | `centos-stream-9-x64` |
| `debian-9` | `debian-9-x64` |
| `debian-10` | `debian-10-x64` |
| `debian-11` | `debian-11-x64` |
| `debian-12` | `debian-12-x64` |
| `debian-13` | `debian-13-x64` |
| `fedora-32` | `fedora-32-x64` |
| `fedora-33` | `fedora-33-x64` |
| `fedora-41` | `fedora-41-x64` |
| `fedora-42` | `fedora-42-x64` |
| `freebsd-11` | `freebsd-11-x64-zfs` |
| `freebsd-12` | `freebsd-12-x64-zfs` |
| `freebsd-13` | `freebsd-13-x64-zfs` |
| `freebsd-14` | `freebsd-14-x64-zfs` |
| `rockylinux-8` | `rockylinux-8-x64` |
| `rockylinux-9` | `rockylinux-9-x64` |
| `ubuntu-16` | `ubuntu-16-04-x64` |
| `ubuntu-18` | `ubuntu-18-04-x64` |
| `ubuntu-20` | `ubuntu-20-04-x64` |
| `ubuntu-22` | `ubuntu-22-04-x64` |
| `ubuntu-24` | `ubuntu-24-04-x64` |

Anything that is not in that list is passed to the API untouched, so you can use
a full slug or a private image ID as the platform name directly:

```yaml
platforms:
  - name: ubuntu-24-04-x64     # an image slug
  - name: "123456789"          # a private image ID
```

You can also set the image explicitly and give the platform any name you like:

```yaml
platforms:
  - name: my-golden-image
    driver:
      image: "123456789"
```

`doctl compute image list --public` lists every slug available to your account.

## Examples

### Different sizes and regions per platform

```yaml
driver:
  name: digitalocean
  region: nyc3

platforms:
  - name: ubuntu-24
  - name: debian-13
    driver:
      size: s-2vcpu-4gb
      region: lon1
```

### Tags and cloud firewalls

```yaml
driver:
  name: digitalocean
  tags:
    - test-kitchen
    - ci
  firewalls:
    - 8b1b4e04-a4d9-4b52-9b1c-5d2a52f39cf0
```

Tags are handy for cleanup: `doctl compute droplet delete --tag-name test-kitchen`
removes everything a CI run left behind.

### VPC placement

```yaml
driver:
  name: digitalocean
  vpcs: 3a92ae2d-f1b7-4589-81b8-8ef144374453
```

### Cloud-init user data

```yaml
driver:
  name: digitalocean
  user_data: |
    #cloud-config
    package_update: true
    packages:
      - curl
```

### Non-root SSH user

Some images ship with a non-root default account. Point the transport at it:

```yaml
driver:
  name: digitalocean
  username: admin

transport:
  username: admin
```

## Troubleshooting

### `config[:digitalocean_access_token] cannot be blank`

`DIGITALOCEAN_ACCESS_TOKEN` is not set in the shell running `kitchen`. Note that
`sudo` and most CI runners do not forward environment variables by default.

### `config[:ssh_key_ids] cannot be blank`

Set `DIGITALOCEAN_SSH_KEY_IDS` (or `SSH_KEY_IDS`), or add `ssh_key_ids` to the
`driver` block.

### `The DigitalOcean API request failed: 401 ...`

The token is wrong, expired, or read-only. Generate a new one with write scope.

### `The DigitalOcean API request failed: 422 ...`

The API rejected the Droplet. The message says why — usually a `size` that is not
offered in the chosen `region`, or an image slug that does not exist. Check with
`doctl compute size list` and `doctl compute image list --public`.

### `The DigitalOcean API rate limit was still in force after 5 retries`

DigitalOcean allows 250 requests a minute. A large `kitchen test` matrix polls
hard enough to reach that, and the driver waits out the window and retries on
its own — this message means it was still rate limited after five waits. Run
fewer instances at once with `kitchen test --concurrency`, or raise
`server_wait_interval` so each instance polls less often.

### `The DigitalOcean API could not be reached: ...`

A network or TLS failure rather than an API error. Lookups and deletes are
retried automatically; a Droplet **create** is not, because a dropped
connection does not tell you whether the request arrived. If you see this
during `kitchen create`, check the control panel for a Droplet before you
retry, so you do not pay for two.

### `Timed out after 600 seconds waiting for ... to get a public IP address`

The Droplet was created but never got a routable address. Look for it in the
control panel, and raise `server_wait_timeout` if you are in a slow region.

### SSH times out after the Droplet is created

The Droplet is up but your key is not on it. Confirm `ssh_key_ids` names a key
that is actually in your DigitalOcean account, and that the matching private key
is loaded in your agent (`ssh-add -l`).

### Seeing what the driver is doing

Run Test Kitchen with debug logging:

```bash
cinc kitchen test --log-level debug
```

The driver logs every resolved setting. The access token is masked in that
output, so debug logs are safe to paste into a bug report.

### Cleaning up

If a run is interrupted, the Droplet may outlive it. `cinc kitchen destroy` is the
first thing to try. If Test Kitchen has lost track of the instance, delete it by
name or tag:

```bash
doctl compute droplet list
doctl compute droplet delete <droplet-name>
```

## Using with Chef

This driver is not tied to Cinc. The examples above use Cinc Workstation and the
`cinc_infra` provisioner, but the driver works exactly the same with
[Chef Workstation](https://www.chef.io/downloads/tools/workstation) — run
`kitchen` instead of `cinc kitchen`, and use `chef_infra` instead of
`cinc_infra`:

```yaml
provisioner:
  name: chef_infra

verifier:
  name: inspec
```

No driver configuration changes are needed.

## Contributing

Pull requests are very welcome. See [CONTRIBUTING.md](CONTRIBUTING.md) for how to
set up a checkout, run the tests, and get a change merged.

* Source is hosted on [GitHub](https://github.com/test-kitchen/kitchen-digitalocean).
* Report issues and feature requests on [GitHub Issues](https://github.com/test-kitchen/kitchen-digitalocean/issues).

## Authors

Created and maintained by [Greg Fitzgerald](https://github.com/gregf/).

Originally adapted from [RoboticCheese](https://github.com/RoboticCheese)'s
[kitchen-rackspace](https://github.com/RoboticCheese/kitchen-rackspace) driver.
Thanks also to [Will Farrington](https://github.com/wfarr/kitchen-digital_ocean),
whose fork helped during the creation of the v2 API driver.

## License

Apache 2.0. See [LICENSE](LICENSE).
