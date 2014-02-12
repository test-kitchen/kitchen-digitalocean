[![Gem Version](https://badge.fury.io/rb/kitchen-digitalocean.png)](http://badge.fury.io/rb/kitchen-digitalocean) [![Build Status](https://travis-ci.org/gregf/kitchen-digitalocean.png?branch=master)](https://travis-ci.org/gregf/kitchen-digitalocean) [![Code Climate](https://codeclimate.com/github/gregf/kitchen-digitalocean.png)](https://codeclimate.com/github/gregf/kitchen-digitalocean) [![Dependency Status](https://gemnasium.com/gregf/kitchen-digitalocean.png)](https://gemnasium.com/gregf/kitchen-digitalocean)

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
source https://rubygems.org

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
export SSH_KEY_IDS="1234, 5678"
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
- name: centos-5.8
- name: centos-6.4
- name: centos-6.5
- name: debian-6.0
- name: debian-7.0
- name: fedora-17
- name: fedora-19
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
