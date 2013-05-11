[![Build Status](https://travis-ci.org/gregf/kitchen-digitalocean.png?branch=master)](https://travis-ci.org/gregf/kitchen-digitalocean) [![Code Climate](https://codeclimate.com/github/gregf/kitchen-digitalocean.png)](https://codeclimate.com/github/gregf/kitchen-digitalocean) [![Dependency Status](https://gemnasium.com/gregf/kitchen-digitalocean.png)](https://gemnasium.com/gregf/kitchen-digitalocean)

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
```

### List of Flavors
```shell
ID      Distribution  Name                      Global
249545  Arch Linux    Arch Linux 2013.03 x32    +
249546  Arch Linux    Arch Linux 2013.03 x64    +
1602    CentOS        CentOS 5.8 x32            +
1601    CentOS        CentOS 5.8 x64            +
1605    CentOS        CentOS 6.0 x32            +
1611    CentOS        CentOS 6.2 x64            +
12578   CentOS        CentOS 6.3 x32            +
12574   CentOS        CentOS 6.3 x64            +
196798  CentOS        Centos 6.4 x32 Server     +
197088  CentOS        Centos 6.4 x64 Server     +
12575   Debian        Debian 6.0 x32            +
12573   Debian        Debian 6.0 x64            +
1606    Fedora        Fedora 15 x64             +
1618    Fedora        Fedora 16 x64 Desktop     +
1615    Fedora        Fedora 16 x64 Server      +
32399   Fedora        Fedora 17 x32 Desktop     +
32387   Fedora        Fedora 17 x32 Server      +
32419   Fedora        Fedora 17 x64 Desktop     +
32428   Fedora        Fedora 17 x64 Server      +
46964   Ubuntu        LAMP on Ubuntu 12.04      +
14098   Ubuntu        Ubuntu 10.04 x32 Server   +
14097   Ubuntu        Ubuntu 10.04 x64 Server   +
43462   Ubuntu        Ubuntu 11.04x32 Desktop   +
43458   Ubuntu        Ubuntu 11.04x64 Server    +
1609    Ubuntu        Ubuntu 11.10 x32 Server   +
42735   Ubuntu        Ubuntu 12.04 x32 Server   +
14218   Ubuntu        Ubuntu 12.04 x64 Desktop  +
2676    Ubuntu        Ubuntu 12.04 x64 Server   +
25485   Ubuntu        Ubuntu 12.10 x32 Desktop  +
25306   Ubuntu        Ubuntu 12.10 x32 Server   +
25493   Ubuntu        Ubuntu 12.10 x64 Desktop  +
25489   Ubuntu        Ubuntu 12.10 x64 Server   +
```

### List of Sizes
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
