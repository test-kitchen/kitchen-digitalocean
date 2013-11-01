[![Gem Version](https://badge.fury.io/rb/kitchen-digitalocean.png)](http://badge.fury.io/rb/kitchen-digitalocean) [![Build Status](https://travis-ci.org/gregf/kitchen-digitalocean.png?branch=master)](https://travis-ci.org/gregf/kitchen-digitalocean) [![Code Climate](https://codeclimate.com/github/gregf/kitchen-digitalocean.png)](https://codeclimate.com/github/gregf/kitchen-digitalocean) [![Dependency Status](https://gemnasium.com/gregf/kitchen-digitalocean.png)](https://gemnasium.com/gregf/kitchen-digitalocean)

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
region. Additional, optional settings can be provided:

    image_id: [SERVER IMAGE ID]
    flavor_id: [SERVER FLAVOR ID]
    name: [A UNIQUE SERVER NAME]
    region_id: [A VALID DIGITAL OCEAN REGION ID]
    ssh_key_ids: [COMMA SEPERATED SSH KEY IDS FROM DIGITAL OCEAN]

### List of Regions

```shell
ID  Name
1   New York 1
2   Amsterdam 1
3   San Francisco 1
4   New York 2
```

### List of Images
```shell
ID       Distribution  Name
361740   Arch Linux    Arch Linux 2013.05 x32
350424   Arch Linux    Arch Linux 2013.05 x64
1602     CentOS        CentOS 5.8 x32
1601     CentOS        CentOS 5.8 x64
376568   CentOS        CentOS 6.4 x32
562354   CentOS        CentOS 6.4 x64
12575    Debian        Debian 6.0 x32
12573    Debian        Debian 6.0 x64
303619   Debian        Debian 7.0 x32
308287   Debian        Debian 7.0 x64
32387    Fedora        Fedora 17 x32
32399    Fedora        Fedora 17 x32 Desktop
32428    Fedora        Fedora 17 x64
32419    Fedora        Fedora 17 x64 Desktop
697056   Fedora        Fedora 19 x86
696598   Fedora        Fedora 19 x86-64
1004145  Ubuntu        Docker on Ubuntu 13.04 x64
959207   Ubuntu        Ghost 0.3.3 on Ubuntu 12.04
459444   Ubuntu        LAMP on Ubuntu 12.04
483575   Ubuntu        Redmine on Ubuntu 12.04
464235   Ubuntu        Ruby on Rails on Ubuntu 12.10 (Nginx + Unicorn)
14098    Ubuntu        Ubuntu 10.04 x32
14097    Ubuntu        Ubuntu 10.04 x64
284211   Ubuntu        Ubuntu 12.04 x32
284203   Ubuntu        Ubuntu 12.04 x64
1015250  Ubuntu        Ubuntu 12.04.3 x32
1015253  Ubuntu        Ubuntu 12.04.3 x64
433240   Ubuntu        Ubuntu 12.10 x32
473123   Ubuntu        Ubuntu 12.10 x64
473136   Ubuntu        Ubuntu 12.10 x64 Desktop
345791   Ubuntu        Ubuntu 13.04 x32
350076   Ubuntu        Ubuntu 13.04 x64
962304   Ubuntu        Ubuntu 13.10 x32
961965   Ubuntu        Ubuntu 13.10 x64
1061995  Ubuntu        Wordpress on Ubuntu 12.10
```

### List of Flavors (Sizes)
```shell
ID  Name
63  1GB
62  2GB
64  4GB
65  8GB
61  16GB
60  32GB
70  48GB
69  64GB
68  96GB
66  512MB
```

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
