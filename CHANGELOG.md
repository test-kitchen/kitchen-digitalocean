# 0.9.6 / 2017-07-27

* [@martinisoft] Bump droplet_kit to latest 2.0 series release

# 0.9.5 / 2015-12-14

* This release fixes the slugs I accidentally broke in 0.9.4.

# 0.9.4 / 2015-12-14

* Update slug mappings.

# 0.9.3 / 2015-08-21

* Show user_data option in debug output.
* Default to 'nologin' when Etc.getlogin doesn't work (windows).

# 0.9.2 / 2015-07-20

* [@joonas](https://github.com/joonas) [PR #41] Add the ability to map well-known platforms to slugs

# 0.9.1 / 2015-06-19

* [@olivielpeau](https://github.com/olivielpeau) [PR #40] Destroy properly droplets that are still "new"

# 0.9.0 / 2015-04-17

* [@juliandunn](https://github.com/juliandunn) [PR #37] Added the ability to pass user_data into droplet creation.

# 0.8.3 / 2014-12-29

* [@RoboticCheese](https://github.com/RoboticCheese) [PR #34] make key IDs always a String

# 0.8.2 / 2014-11-09

* Handle API errors more gracefully, closes issue #33.

# 0.8.1 / 2014-10-13

* [@sarkis](https://github.com/sarkis) [PR #32] fix driver config example
* [@sarkis](https://github.com/sarkis) [PR #31] make sure there are no underscores in hostname
* [@sarkis](https://github.com/sarkis) [PR #30] properly split ssh key ids

# 0.8.0 / 2014-8-21

* [@RoboticCheese](https://github.com/RoboticCheese) [PR #25] Sanitize default names, limit to 63 chars

# 0.8.0.pre1 / 2014-08-21

***Breaking Changes***

From this version on the driver uses API V2, the use of image_id, flavor_id, and region_id has been replaced
with image, size, region. You can now rely on slugs instead of uses IDs. Please refer to the readme for additional information.

* Upgrade to API V2
* Drop Fog, for [droplet_kit](https://github.com/digitaloceancloud/droplet_kit)

# 0.7.3 / 2014-08-19

* Add id for New York 3
* Update various other data id's
* [@sample](https://github.com/sample) [PR #23] Fix Debian 7.0 id
* [@skottler](https://github.com/skottler) [PR #22] Update the ID for precise
* [@RoboticCheese](https://github.com/RoboticCheese) [PR #21] Update README to reflect latest platform list

# 0.7.2 / 2014-07-24

* [@RoboticCheese](https://github.com/RoboticCheese) [PR #20] Update to latest image IDs
* [@ijin](https://github.com/ijin)[PR #19] Update image id list & readme
* [@ishakir](https://github.com/ishakir)[PR #18] Gemfile syntax incorrect
* [@alaa](https://github.com/alaa)[PR #17] Update ssh_key API in the README file

# 0.7.1 / 2014-06-23

* [@RoboticCheese](https://github.com/RoboticCheese) [PR #16] Use the 64-bit CentOS 6.5 image.

# 0.7.0 / 2014-05-20

* [@zhann](https://github.com/Zhann) [PR #15] Makes hostnames RFC compatible
* [@coderanger](https://github.com/coderanger) [PR #14] New image ID for centos-6.5
* [@coderanger](https://github.com/coderanger) [PR #13] Allow using a correctly name-scoped environment variable for ssh_key_ids

# 0.6.4 / 2014-05-02

* Update image list.

# 0.6.3 / 2014-04-28

* I messed up the release process for 0.6.2 and yanked it, this is the same as 0.6.2 was meant to be, sorry.

# 0.6.2 / 2014-04-28

* [@juliandunn](https://github.com/juliandunn) [PR #11] Updated new image IDs from DigitalOcean.

# 0.6.1 / 2014-04-12

* [@juliandunn](https://github.com/juliandunn) [PR #9] DigitalOcean updated some images so the IDs required fixing.

# 0.6.0 / 2014-03-17

* Private Networking is now enabled by default. This only works in select regions.
* The default region was changed to New York 2, so private networking would work by default.

# 0.5.2 / 2014-02-20

* [@lamont-granquist](https://github.com/lamont-granquist) [PR #5] add info on using numeric key ids.
* [@mattwhite](https://github.com/mattwhite) [PR #6] Add Ubuntu 12.04 support.

# 0.5.1 / 2014-02-11

* Add new Singapore 1 region
* Fixed up the readme

# 0.5.0 / 2013-12-31

* You can alternatively use region and flavor options instead of their _id counter parts.
  See the readme for more information.

# 0.4.0 / 2013-12-31

* Updated the driver for test kitchen 1.1, fixed some bugs.
* Improved documentation
* It will now read your api key, client id, and ssh key ids, from environment variables if set.
* You can specify the image name rather than the image id

# 0.3.1 / 2013-12-29

* [@someara](https://github.com/someara) [PR #2] Relax test-kitchen version dep

# 0.3.0 / 2013-12-12

* Fix deprecation warnings from rspec 3
* Bump test-kitchen dependency to ~> 1.1.0

# 0.2.1 / 2013-10-31

* Update example tables in the readme
* Fix warning for public_ip_address
* [@dpetzel](https://github.com/dpetzel) [PR #1] flip flavor and image

# 0.2.0 / 2013-06-19

* Provide debug output for test-kitchen
* Visual feedback during server creation
* Use ruby 1.9 hash syntax
* Bump fog dependency to 1.12

# 0.1.0 / 2013-05-12

* Initial release
