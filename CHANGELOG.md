# 0.6.0 / 2014-3-17

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
