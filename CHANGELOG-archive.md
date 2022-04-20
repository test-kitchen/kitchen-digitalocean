# Changelog Archive

Archive of changelog entries pre-please-release.

## 0.14.0 / 2021-10-01

- Add Debian 11 slug

## 0.13.0 / 2021-07-02

- Switch to Chefstyle for Ruby linting
- Support Test Kitchen 3.0

## 0.12.0 / 2021-04-12

- Update all the platform slugs for the latest versions available in DigitalOcean
  - Remove CoreOS
  - Remoe Ubuntu17
  - Remove CentOS6
  - Add RancherOS
- Move the getting started docs to the new docs page at <https://kitchen.ci/docs/drivers/digitalocean/>

## 0.11.2 / 2020-09-20

- [@tas50] [PR #79] Swap to_yaml for YAML.dump

## 0.11.1 / 2020-08-21

- [@tas50] [PR #78] Optimize our requires

## 0.11.0 / 2020-05-18

- Add support for VPC, closes issue #75

## 0.10.7 / 2020-05-18

- [@vsingh-msys] [PR #77] Remove unsupported default image mapping

## 0.10.6 / 2020-03-25

- [@zmaupin] [PR #74] Update default size to 1GB
- [@tolland] [PR #73] add fedora-31 and centos-8 slugs
- [@tas50] [PR #72] Test on the latest ruby releases

## 0.10.5 / 2019-10-22

- Add Debian-10 and FreeBSD-12 image aliases

## 0.10.4 / 2019-06-28

- [@bdausses] [PR #67] Added ability to apply monitoring at droplet creation.
- [@tolland] [PR #69] adding new slugs
- [@esoterick] [PR #70] feature: default region environment variable

## 0.10.3 / 2019-03-20

- Loosen dependencies

## 0.10.2 / 2019-02-15

- Update gem versions
- Expose ipv4 address in debug information
- Fix rubocop warnings

## 0.10.1 / 2018-10-05

- [@tas50] [PR #64] Slim the size of the Gem and standardize the license file / string
- Add new FreeBSD 10.4/11.2 slugs
- Make DigitalOcean a single word in logging

## 0.10.0 / 2018-06-13

- Bump droplet_kit to latest 2.3 series release
- Rubocop fixes
- [@tolland] [PR #59] Add tags attribute to the driver config
- [@tolland] [PR #58] Add firewalls attribute to driver config
- [@tolland] [PR #57] Update image slugs for ubuntu 17, 18, fedora 27, 28

## 0.9.8 / 2017-09-09

- After the 0.9.7 release I noticed the nyc2 datacenter we were defaulting to no longer exists, now defaulting to nyc1.

## 0.9.7 / 2017-09-09

- Update slug abbrevations
- Bump a few testing tools in the gemspec file
- Fix some rubocop warnings
- Fix tests

## 0.9.6 / 2017-07-27

- [@martinisoft] Bump droplet_kit to latest 2.0 series release

## 0.9.5 / 2015-12-14

- This release fixes the slugs I accidentally broke in 0.9.4.

## 0.9.4 / 2015-12-14

- Update slug mappings.

## 0.9.3 / 2015-08-21

- Show user_data option in debug output.
- Default to 'nologin' when Etc.getlogin doesn't work (windows).

## 0.9.2 / 2015-07-20

- [@joonas](https://github.com/joonas) [PR #41] Add the ability to map well-known platforms to slugs

## 0.9.1 / 2015-06-19

- [@olivielpeau](https://github.com/olivielpeau) [PR #40] Destroy properly droplets that are still "new"

## 0.9.0 / 2015-04-17

- [@juliandunn](https://github.com/juliandunn) [PR #37] Added the ability to pass user_data into droplet creation.

## 0.8.3 / 2014-12-29

- [@RoboticCheese](https://github.com/RoboticCheese) [PR #34] make key IDs always a String

## 0.8.2 / 2014-11-09

- Handle API errors more gracefully, closes issue #33.

## 0.8.1 / 2014-10-13

- [@sarkis](https://github.com/sarkis) [PR #32] fix driver config example
- [@sarkis](https://github.com/sarkis) [PR #31] make sure there are no underscores in hostname
- [@sarkis](https://github.com/sarkis) [PR #30] properly split ssh key ids

## 0.8.0 / 2014-8-21

- [@RoboticCheese](https://github.com/RoboticCheese) [PR #25] Sanitize default names, limit to 63 chars

## 0.8.0.pre1 / 2014-08-21

**_Breaking Changes_**

From this version on the driver uses API V2, the use of image_id, flavor_id, and region_id has been replaced with image, size, region. You can now rely on slugs instead of uses IDs. Please refer to the readme for additional information.

- Upgrade to API V2
- Drop Fog, for [droplet_kit](https://github.com/digitaloceancloud/droplet_kit)

## 0.7.3 / 2014-08-19

- Add id for New York 3
- Update various other data id's
- [@sample](https://github.com/sample) [PR #23] Fix Debian 7.0 id
- [@skottler](https://github.com/skottler) [PR #22] Update the ID for precise
- [@RoboticCheese](https://github.com/RoboticCheese) [PR #21] Update README to reflect latest platform list

## 0.7.2 / 2014-07-24

- [@RoboticCheese](https://github.com/RoboticCheese) [PR #20] Update to latest image IDs
- [@ijin](https://github.com/ijin) [PR #19] Update image id list & readme
- [@ishakir](https://github.com/ishakir) [PR #18] Gemfile syntax incorrect
- [@alaa](https://github.com/alaa) [PR #17] Update ssh_key API in the README file

## 0.7.1 / 2014-06-23

- [@RoboticCheese](https://github.com/RoboticCheese) [PR #16] Use the 64-bit CentOS 6.5 image.

## 0.7.0 / 2014-05-20

- [@zhann](https://github.com/Zhann) [PR #15] Makes hostnames RFC compatible
- [@coderanger](https://github.com/coderanger) [PR #14] New image ID for centos-6.5
- [@coderanger](https://github.com/coderanger) [PR #13] Allow using a correctly name-scoped environment variable for ssh_key_ids

## 0.6.4 / 2014-05-02

- Update image list.

## 0.6.3 / 2014-04-28

- I messed up the release process for 0.6.2 and yanked it, this is the same as 0.6.2 was meant to be, sorry.

## 0.6.2 / 2014-04-28

- [@juliandunn](https://github.com/juliandunn) [PR #11] Updated new image IDs from DigitalOcean.

## 0.6.1 / 2014-04-12

- [@juliandunn](https://github.com/juliandunn) [PR #9] DigitalOcean updated some images so the IDs required fixing.

## 0.6.0 / 2014-03-17

- Private Networking is now enabled by default. This only works in select regions.
- The default region was changed to New York 2, so private networking would work by default.

## 0.5.2 / 2014-02-20

- [@lamont-granquist](https://github.com/lamont-granquist) [PR #5] add info on using numeric key ids.
- [@mattwhite](https://github.com/mattwhite) [PR #6] Add Ubuntu 12.04 support.

## 0.5.1 / 2014-02-11

- Add new Singapore 1 region
- Fixed up the readme

## 0.5.0 / 2013-12-31

- You can alternatively use region and flavor options instead of their _id counter parts. See the readme for more information.

## 0.4.0 / 2013-12-31

- Updated the driver for test kitchen 1.1, fixed some bugs.
- Improved documentation
- It will now read your api key, client id, and ssh key ids, from environment variables if set.
- You can specify the image name rather than the image id

## 0.3.1 / 2013-12-29

- [@someara](https://github.com/someara) [PR #2] Relax test-kitchen version dep

## 0.3.0 / 2013-12-12

- Fix deprecation warnings from rspec 3
- Bump test-kitchen dependency to ~> 1.1.0

## 0.2.1 / 2013-10-31

- Update example tables in the readme
- Fix warning for public_ip_address
- [@dpetzel](https://github.com/dpetzel) [PR #1] flip flavor and image

## 0.2.0 / 2013-06-19

- Provide debug output for test-kitchen
- Visual feedback during server creation
- Use ruby 1.9 hash syntax
- Bump fog dependency to 1.12

## 0.1.0 / 2013-05-12

- Initial release
