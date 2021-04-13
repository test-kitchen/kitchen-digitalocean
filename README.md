<img src="/assets/do_logo.png" alt="DO Logo">

Now proudly sponsored by [DigitalOcean](https://www.digitalocean.com).

[![Gem Version](https://badge.fury.io/rb/kitchen-digitalocean.svg)](http://badge.fury.io/rb/kitchen-digitalocean)
[![Build Status](https://travis-ci.org/test-kitchen/kitchen-digitalocean.svg?branch=master)](https://travis-ci.org/test-kitchen/kitchen-digitalocean)

# Kitchen::Digitalocean

A Test Kitchen Driver for [DigitalOcean](https://www.digitalocean.com).

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

```bash
gem install kitchen-digitalocean
```

or add it to your Gemfile if you are using [Bundler](http://bundler.io/)

```ruby
source 'https://rubygems.org'

gem 'test-kitchen'
gem 'kitchen-digitalocean'
```

# Getting Started

For help getting started check the [kitchen.ci DigitalOcean Driver documentation](https://kitchen.ci/docs/drivers/digitalocean/)

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
5. Create a new Pull Request

# Authors

Created and maintained by [Greg Fitzgerald](https://github.com/gregf/) (<greg@gregf.org>)

***Special Thanks:***

[Will Farrington](https://github.com/wfarr/kitchen-digital_ocean), His fork was a help during the creation of my api v2 driver.

# License

Apache 2.0 (see [LICENSE](https://github.com/test-kitchen/kitchen-digitalocean/blob/master/LICENSE.txt))
