[![Gem Version](https://badge.fury.io/rb/kitchen-digitalocean.svg)](http://badge.fury.io/rb/kitchen-digitalocean) 
[![Build Status](https://travis-ci.org/test-kitchen/kitchen-digitalocean.png?branch=master)](https://travis-ci.org/test-kitchen/kitchen-digitalocean) 
[![Code Climate](https://codeclimate.com/github/test-kitchen/kitchen-digitalocean.png)](https://codeclimate.com/github/test-kitchen/kitchen-digitalocean) 
[![Coverage Status](https://coveralls.io/repos/test-kitchen/kitchen-digitalocean/badge.svg?branch=master)](https://coveralls.io/r/test-kitchen/kitchen-digitalocean?branch=master)
[![Dependency Status](https://gemnasium.com/test-kitchen/kitchen-digitalocean.svg)](https://gemnasium.com/test-kitchen/kitchen-digitalocean)

# Kitchen::Digitalocean

A Test Kitchen Driver for Digital Ocean

Shamelessly copied from [RoboticCheese](https://github.com/RoboticCheese)'s
awesome work on an [Rackspace driver](https://github.com/RoboticCheese/kitchen-rackspace).

# Upgrading

From this version forward the driver uses [API V2](https://developers.digitalocean.com/) only.
Use of image_id, flavor_id, and region_id have been replaced with image, size, and region.
You can now use slugs instead of relying on the old data.json to translate IDs. 
Please refer to the examples below, and the API documentation for more information.

# Requirements

There are no external system requirements for this driver. However you will need access to an [DigitalOcean](https://digitalocean.com/) account.

# Installation and Setup

You'll need to install the gem on your development machine.

```Bash
gem install kitchen-digitalocean
```

or add it to your Gemfile if you are using [Bundler](http://bundler.io/)

```ruby
source 'https://rubygems.org'

gem 'test-kitchen'
gem 'kitchen-digitalocean'
```

At minimum, you'll need to tell test-kitchen to use the digitalocean driver.

```ruby
---
driver:
  name: digitalocean
platforms:
  - name: ubuntu-17
```

You also have the option of providing your credentials from environment variables.

```bash
export DIGITALOCEAN_ACCESS_TOKEN="1234"
export DIGITALOCEAN_SSH_KEY_IDS="1234, 5678"
```

Note that your `SSH_KEY_ID` must be the numeric id of your ssh key, not the symbolic name. To get the numeric ID
of your keys, use something like to following command to get them from the digital ocean API:

```bash
curl -X GET https://api.digitalocean.com/v2/account/keys -H "Authorization: Bearer $DIGITALOCEAN_ACCESS_TOKEN"
```

Please refer to the [Getting Started Guide](http://kitchen.ci/) for any further documentation.

# Default Configuration

The driver now uses api v2 which provides slugs for image names, sizes, and regions.

Example configuration:

```ruby
---
platforms:
- name: debian-7-0-x64
  driver_config:
    region: ams1
- name: centos-6-4-x64
  driver_config:
    size: 2gb
# ...
```

# Private Networking

Private networking is enabled by default, but will only work in certain regions. You can disable private networking by changing private_networking to
false. Example below.

```ruby
---
driver:
  - private_networking: false
```

# IPv6

IPv6 is disabled by default, you can enable this if needed. IPv6 is only available in limited regions.


```ruby
---
driver:
  - ipv6: true
```

# Image abbrevations we use

This is a list of abbreviate image names we provide

```
centos-6
centos-7
coreos-stable
oreos-beta
coreos-alpha
debian-7
ebian-8
debian-9
fedora-24
fedora-25
fedora-26
reebsd-11.1
freebsd-11.0
freebsd-10.3
ubuntu-14
ubuntu-16
ubuntu-17
```

# Regions

```
nyc1    New York 1
sfo1    San Francisco 1
ams2    Amsterdam 2
sgp1    Singapore 1
lon1    London 1
nyc3    New York 3
ams3    Amsterdam 3
fra1    Frankfurt 1
tor1    Toronto 1
sfo2    San Francisco 2
blr1    Bangalore 1
```

# Development

* Source hosted at [GitHub](https://github.com/test-kitchen/kitchen-digitalocean)
* Report issues/questions/feature requests on [GitHub Issues](https://github.com/test-kitchen/kitchen-digitalocean/issues)

Pull requests are very welcome! Make sure your patches are well tested.
Ideally create a topic branch for every separate change you make. For
example:

1. Fork the repo
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Added some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request

# Authors

Created and maintained by [Greg Fitzgerald](https://github.com/gregf/) (<greg@gregf.org>)

***Special Thanks:***

[Will Farrington](https://github.com/wfarr/kitchen-digital_ocean), His fork was a help during the creation of my api v2 driver.

# License

Apache 2.0 (see [LICENSE](https://github.com/test-kitchen/kitchen-digitalocean/blob/master/LICENSE.txt))
