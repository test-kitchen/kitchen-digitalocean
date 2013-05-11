[![Build Status](https://travis-ci.org/gregf/kitchen-digitalocean.png?branch=master)](https://travis-ci.org/gregf/kitchen-digitalocean) [![Code Climate](https://codeclimate.com/github/gregf/kitchen-digitalocean.png)](https://codeclimate.com/github/gregf/kitchen-digitalocean)

# Kitchen::Digitalocean

A Digital Ocean driver for Test Kitchen 1.0!

Shamelessly copied from [RoboticCheese](https://github.com/RoboticCheese)'s
awesome work on an [Rackspace driver](https://github.com/RoboticCheese/kitchen-rackspace).

## Installation

Add this line to your application's Gemfile:

    gem 'kitchen-digitalocean'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install kitchen-digitalocean

## Usage

Provide, at a minimum, the required driver options in your `.kitchen.yml` file:

    driver_plugin: digitalocean
    driver_config:
      digitalocean_client_id: [YOUR DIGITAL OCEAN CLIENT ID]
      digitalocean_api_key: [YOUR DIGITAL OCEAN API KEY]
      require_chef_omnibus: latest (if you'll be using Chef)

By default, the driver will spawn a 512MB Ubuntu 12.10 instance in the New York
Digital Ocean region. Additional, optional settings can be provided:

    image_id: [SERVER IMAGE ID]
    flavor_id: [SERVER FLAVOR ID]
    name: [A UNIQUE SERVER NAME]
    region_id: [A VALID DIGITAL OCEAN REGION ID]
    ssh_key_ids: [SSH KEY ID FROM DIGITAL OCEAN]

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
