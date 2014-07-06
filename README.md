[![Gem Version](https://badge.fury.io/rb/kitchen-digitalocean.png)](http://badge.fury.io/rb/kitchen-digitalocean) [![Build Status](https://travis-ci.org/test-kitchen/kitchen-digitalocean.png?branch=master)](https://travis-ci.org/test-kitchen/kitchen-digitalocean) [![Code Climate](https://codeclimate.com/github/test-kitchen/kitchen-digitalocean.png)](https://codeclimate.com/github/test-kitchen/kitchen-digitalocean) [![Dependency Status](https://gemnasium.com/test-kitchen/kitchen-digitalocean.png)](https://gemnasium.com/test-kitchen/kitchen-digitalocean)

# Kitchen::Digitalocean

A Test Kitchen Driver for Digital Ocean

Shamelessly copied from [RoboticCheese](https://github.com/RoboticCheese)'s
awesome work on an [Rackspace driver](https://github.com/RoboticCheese/kitchen-rackspace).

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
  - name: digitalocean
platforms:
  - name: ubuntu-12.10
```

You also have the option of providing your credentials from environment variables.

```bash
export DIGITALOCEAN_CLIENT_ID="1234"
export DIGITALOCEAN_API_KEY="5678"
export DIGITALOCEAN_SSH_KEY_IDS="1234, 5678"
```

Note that your `SSH_KEY_ID` must be the numeric id of your ssh key, not the symbolic name. To get the numeric ID
of your keys, use something like to following command to get them from the digital ocean API:

```bash
curl -X GET https://api.digitalocean.com/v2/account/keys -H "Authorization: Bearer $DIGITALOCEAN_API_KEY"
```

Please refer to the [Getting Started Guide](http://kitchen.ci/) for any further documentation.

# Default Configuration

This driver can determine the image_id for a select number of platforms in each region. Currently, the following platform names are supported:

```ruby
---
platforms:
- name: ubuntu-10.04
- name: ubuntu-12.10
- name: ubuntu-13.04
- name: ubuntu-13.10
- name: ubuntu-14.04
- name: centos-5.8
- name: centos-6.4
- name: centos-6.5
- name: debian-6.0
- name: debian-7.0
- name: fedora-19
- name: fedora-20
- name: archlinux-2013.05
```

This will effectively generate a configuration similar to:

```ruby
---
platforms:
- name: ubuntu-10.04
  driver_config:
    image_id: 14097
- name: ubuntu-12.10
  driver_config:
    image_id: 473123
# ...
- name: centos-5.8
  driver_config:
    image_id: 1601
# ...
```

`flavor_id` and `region_id` can be set from the more friendly options flavor, and region like so.

```ruby
driver:
- region: amsterdam 2
- flavor: 8GB
```

This will generate a configuration similiar to:

```ruby
---
driver:
- region_id: 5
- flavor: 65
```

For specific default values, please consult [digitalocean.json](https://github.com/test-kitchen/kitchen-digitalocean/blob/master/data/digitalocean.json).

# Private Networking

Private networking is enabled by default, but will only work in certain regions. You can disable private networking by changing private_networking to
false. Example below.

```ruby
---
driver:
  - private_networking: false
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

# License

Apache 2.0 (see [LICENSE](https://github.com/test-kitchen/kitchen-digitalocean/blob/master/LICENSE.txt))
