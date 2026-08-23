# Changelog Archive

Archive of changelog entries pre-please-release.

## [0.14.2](https://github.com/test-kitchen/kitchen-digitalocean/compare/v0.14.1...v0.14.2) (2022-04-21)

* Feat: Use reusable GitHub workflows for testing ([#109](https://github.com/test-kitchen/kitchen-digitalocean/pull/109)) ([fd9d50c](https://github.com/test-kitchen/kitchen-digitalocean/commit/fd9d50c))

* Update chefstyle requirement from = 2.1.0 to = 2.1.1 ([#99](https://github.com/test-kitchen/kitchen-digitalocean/pull/99)) ([c1f02d7](https://github.com/test-kitchen/kitchen-digitalocean/commit/c1f02d7))
* Update chefstyle requirement from = 2.1.1 to = 2.1.3 ([#101](https://github.com/test-kitchen/kitchen-digitalocean/pull/101)) ([950c44f](https://github.com/test-kitchen/kitchen-digitalocean/commit/950c44f))
* Update chefstyle requirement from = 2.1.3 to = 2.2.0 ([#102](https://github.com/test-kitchen/kitchen-digitalocean/pull/102)) ([411e5b1](https://github.com/test-kitchen/kitchen-digitalocean/commit/411e5b1))
* Update chefstyle requirement from = 2.2.0 to = 2.2.2 ([#104](https://github.com/test-kitchen/kitchen-digitalocean/pull/104)) ([245fc99](https://github.com/test-kitchen/kitchen-digitalocean/commit/245fc99))
* run specs on 3.1 and drop 2.5 support ([#105](https://github.com/test-kitchen/kitchen-digitalocean/pull/105)) ([ffd6ca2](https://github.com/test-kitchen/kitchen-digitalocean/commit/ffd6ca2))
* add linters action and publish action ([#106](https://github.com/test-kitchen/kitchen-digitalocean/pull/106)) ([7c9d262](https://github.com/test-kitchen/kitchen-digitalocean/commit/7c9d262))
* Move existing changelog to the archive We wont need to reformat the changelog for the new bot then ([6563271](https://github.com/test-kitchen/kitchen-digitalocean/commit/6563271))
* fix: headings in the changelog archive ([3e00bc7](https://github.com/test-kitchen/kitchen-digitalocean/commit/3e00bc7))
* Rename the lint stage to lint-unit ([cf85261](https://github.com/test-kitchen/kitchen-digitalocean/commit/cf85261))

## 0.14.0 / 2021-10-01

- Add Debian 11 slug

* Update chefstyle requirement from = 2.0.5 to = 2.0.7 ([#94](https://github.com/test-kitchen/kitchen-digitalocean/pull/94)) ([186603d](https://github.com/test-kitchen/kitchen-digitalocean/commit/186603d))
* Update chefstyle requirement from = 2.0.7 to = 2.0.8 ([#95](https://github.com/test-kitchen/kitchen-digitalocean/pull/95)) ([7d094cb](https://github.com/test-kitchen/kitchen-digitalocean/commit/7d094cb))
* Update chefstyle requirement from = 2.0.8 to = 2.1.0 ([#97](https://github.com/test-kitchen/kitchen-digitalocean/pull/97)) ([eea3fa7](https://github.com/test-kitchen/kitchen-digitalocean/commit/eea3fa7))
* add slug for debian 11 ([#98](https://github.com/test-kitchen/kitchen-digitalocean/pull/98)) ([1734f35](https://github.com/test-kitchen/kitchen-digitalocean/commit/1734f35))

## 0.13.0 / 2021-07-02

- Switch to Chefstyle for Ruby linting
- Support Test Kitchen 3.0

* Upgrade to GitHub-native Dependabot ([#90](https://github.com/test-kitchen/kitchen-digitalocean/pull/90)) ([1899235](https://github.com/test-kitchen/kitchen-digitalocean/commit/1899235))
* Convert Ruby linting from RuboCop to Chefstyle ([#92](https://github.com/test-kitchen/kitchen-digitalocean/pull/92)) ([3a9fb2f](https://github.com/test-kitchen/kitchen-digitalocean/commit/3a9fb2f))

## 0.12.0 / 2021-04-12

- Update all the platform slugs for the latest versions available in DigitalOcean
  - Remove CoreOS
  - Remoe Ubuntu17
  - Remove CentOS6
  - Add RancherOS
- Move the getting started docs to the new docs page at <https://kitchen.ci/docs/drivers/digitalocean/>

* Update rubocop requirement from ~&gt; 0.92 to ~&gt; 1.1 ([#82](https://github.com/test-kitchen/kitchen-digitalocean/pull/82)) ([08b3401](https://github.com/test-kitchen/kitchen-digitalocean/commit/08b3401))
* driver/digitalocean: update default slug to match API ([#83](https://github.com/test-kitchen/kitchen-digitalocean/pull/83)) ([e89f9ad](https://github.com/test-kitchen/kitchen-digitalocean/commit/e89f9ad))
* Replace Travis CI testing with GitHub Actions ([#84](https://github.com/test-kitchen/kitchen-digitalocean/pull/84)) ([07b2315](https://github.com/test-kitchen/kitchen-digitalocean/commit/07b2315))
* Add a code of conduct file ([#87](https://github.com/test-kitchen/kitchen-digitalocean/pull/87)) ([2d6c3bf](https://github.com/test-kitchen/kitchen-digitalocean/commit/2d6c3bf))
* Require Ruby 2.5 or later ([#86](https://github.com/test-kitchen/kitchen-digitalocean/pull/86)) ([0b07727](https://github.com/test-kitchen/kitchen-digitalocean/commit/0b07727))
* Update to the latest set of platform slugs + link to docs ([#89](https://github.com/test-kitchen/kitchen-digitalocean/pull/89)) ([15d487c](https://github.com/test-kitchen/kitchen-digitalocean/commit/15d487c))

## 0.11.2 / 2020-09-20

- [@tas50] [PR #79] Swap to_yaml for YAML.dump

* Fix typo in readme ([a9798b5](https://github.com/test-kitchen/kitchen-digitalocean/commit/a9798b5))
* Optimize our requires ([#78](https://github.com/test-kitchen/kitchen-digitalocean/pull/78)) ([42cee80](https://github.com/test-kitchen/kitchen-digitalocean/commit/42cee80))
* Bump ruobocop & run autocorrect ([dbd083e](https://github.com/test-kitchen/kitchen-digitalocean/commit/dbd083e))
* Prep for release ([1ba7a42](https://github.com/test-kitchen/kitchen-digitalocean/commit/1ba7a42))

## 0.11.1 / 2020-08-21

- [@tas50] [PR #78] Optimize our requires

## 0.11.0 / 2020-05-18

- Add support for VPC, closes issue #75

* Add support for VPCS, closes #75 ([d0ab71b](https://github.com/test-kitchen/kitchen-digitalocean/commit/d0ab71b))

## 0.10.7 / 2020-05-18

- [@vsingh-msys] [PR #77] Remove unsupported default image mapping

* Prepare for 0.10.7 release ([042f1e3](https://github.com/test-kitchen/kitchen-digitalocean/commit/042f1e3))

## 0.10.6 / 2020-03-25

- [@zmaupin] [PR #74] Update default size to 1GB
- [@tolland] [PR #73] add fedora-31 and centos-8 slugs
- [@tas50] [PR #72] Test on the latest ruby releases

* Try to add do logo ([c133565](https://github.com/test-kitchen/kitchen-digitalocean/commit/c133565))
* Fix spelling ([6fa4c4a](https://github.com/test-kitchen/kitchen-digitalocean/commit/6fa4c4a))
* Prepare for release ([d5ae935](https://github.com/test-kitchen/kitchen-digitalocean/commit/d5ae935))

## 0.10.5 / 2019-10-22

- Add Debian-10 and FreeBSD-12 image aliases

* Add a powered by note ([d0a85bc](https://github.com/test-kitchen/kitchen-digitalocean/commit/d0a85bc))
* Rubocop all the things again. ([c039bc9](https://github.com/test-kitchen/kitchen-digitalocean/commit/c039bc9))
* Update droplet_kit requirement from ~&gt; 2.8 to &gt;= 2.8, &lt; 4.0 ([#71](https://github.com/test-kitchen/kitchen-digitalocean/pull/71)) ([31f3150](https://github.com/test-kitchen/kitchen-digitalocean/commit/31f3150))
* Update image list ([2e90dd7](https://github.com/test-kitchen/kitchen-digitalocean/commit/2e90dd7))

## 0.10.4 / 2019-06-28

- [@bdausses] [PR #67] Added ability to apply monitoring at droplet creation.
- [@tolland] [PR #69] adding new slugs
- [@esoterick] [PR #70] feature: default region environment variable

* Prepare for release ([29d3728](https://github.com/test-kitchen/kitchen-digitalocean/commit/29d3728))

## 0.10.3 / 2019-03-20

- Loosen dependencies

* Fix versions in the changelog ([026836d](https://github.com/test-kitchen/kitchen-digitalocean/commit/026836d))
* Loosen Test Kitchen and Bundler Deps ([#66](https://github.com/test-kitchen/kitchen-digitalocean/pull/66)) ([28bb884](https://github.com/test-kitchen/kitchen-digitalocean/commit/28bb884))
* Prepare for release ([4992b55](https://github.com/test-kitchen/kitchen-digitalocean/commit/4992b55))

## 0.10.2 / 2019-02-15

- Update gem versions
- Expose ipv4 address in debug information
- Fix rubocop warnings

* Update some of the gems we use ([dcccd4c](https://github.com/test-kitchen/kitchen-digitalocean/commit/dcccd4c))
* Expose public IP in debug information ([62680b1](https://github.com/test-kitchen/kitchen-digitalocean/commit/62680b1))
* Prepare for release ([d493ce2](https://github.com/test-kitchen/kitchen-digitalocean/commit/d493ce2))

## 0.10.1 / 2018-10-05

- [@tas50] [PR #64] Slim the size of the Gem and standardize the license file / string
- Add new FreeBSD 10.4/11.2 slugs
- Make DigitalOcean a single word in logging

* Update badges ([#60](https://github.com/test-kitchen/kitchen-digitalocean/pull/60)) ([a41ee10](https://github.com/test-kitchen/kitchen-digitalocean/commit/a41ee10))
* Test on the latest ruby releases in Travis ([#61](https://github.com/test-kitchen/kitchen-digitalocean/pull/61)) ([cf2c125](https://github.com/test-kitchen/kitchen-digitalocean/commit/cf2c125))
* Add new FreeBSD slugs and fix Digital Ocean -&gt; DigitalOcean ([#62](https://github.com/test-kitchen/kitchen-digitalocean/pull/62)) ([deac299](https://github.com/test-kitchen/kitchen-digitalocean/commit/deac299))
* Prepare for 10.1 release ([86a6875](https://github.com/test-kitchen/kitchen-digitalocean/commit/86a6875))

## 0.10.0 / 2018-06-13

- Bump droplet_kit to latest 2.3 series release
- Rubocop fixes
- [@tolland] [PR #59] Add tags attribute to the driver config
- [@tolland] [PR #58] Add firewalls attribute to driver config
- [@tolland] [PR #57] Update image slugs for ubuntu 17, 18, fedora 27, 28

* Update changelog ([2f11113](https://github.com/test-kitchen/kitchen-digitalocean/commit/2f11113))
* Fixed up some typos ([#55](https://github.com/test-kitchen/kitchen-digitalocean/pull/55)) ([d251e5c](https://github.com/test-kitchen/kitchen-digitalocean/commit/d251e5c))
* Bump droplet_kit and rubocop dependencies ([5de1b4c](https://github.com/test-kitchen/kitchen-digitalocean/commit/5de1b4c))
* Prepare for release ([a067295](https://github.com/test-kitchen/kitchen-digitalocean/commit/a067295))

## 0.9.8 / 2017-09-09

- After the 0.9.7 release I noticed the nyc2 datacenter we were defaulting to no longer exists, now defaulting to nyc1.

* attempt to fix tests, by updating travis.yml ([ef60fe0](https://github.com/test-kitchen/kitchen-digitalocean/commit/ef60fe0))
* Make nyc1 the default, nyc2 is no more ([b1835a3](https://github.com/test-kitchen/kitchen-digitalocean/commit/b1835a3))
* Prepare for release ([28a3040](https://github.com/test-kitchen/kitchen-digitalocean/commit/28a3040))

## 0.9.7 / 2017-09-09

- Update slug abbreviations
- Bump a few testing tools in the gemspec file
- Fix some rubocop warnings
- Fix tests

* Rump dependencies ([ca95e86](https://github.com/test-kitchen/kitchen-digitalocean/commit/ca95e86))
* Rubocop fixes ([25d0bb9](https://github.com/test-kitchen/kitchen-digitalocean/commit/25d0bb9))
* Break up a couple long lines ([0556710](https://github.com/test-kitchen/kitchen-digitalocean/commit/0556710))
* Update image abbrev ([9a72ece](https://github.com/test-kitchen/kitchen-digitalocean/commit/9a72ece))
* Fix failing test ([30fa41e](https://github.com/test-kitchen/kitchen-digitalocean/commit/30fa41e))
* Preapre for release ([49717f9](https://github.com/test-kitchen/kitchen-digitalocean/commit/49717f9))

## 0.9.6 / 2017-07-27

- [@martinisoft] Bump droplet_kit to latest 2.0 series release

* Add slug for 16.04 ([#46](https://github.com/test-kitchen/kitchen-digitalocean/pull/46)) ([c05a99f](https://github.com/test-kitchen/kitchen-digitalocean/commit/c05a99f))
* fix travis errors ([#48](https://github.com/test-kitchen/kitchen-digitalocean/pull/48)) ([2fa4c88](https://github.com/test-kitchen/kitchen-digitalocean/commit/2fa4c88))
* Update readme badges ([#50](https://github.com/test-kitchen/kitchen-digitalocean/pull/50)) ([609b735](https://github.com/test-kitchen/kitchen-digitalocean/commit/609b735))
* Fix deprecation warning around SimpleCov::Formatter::MultiFormatter ([#47](https://github.com/test-kitchen/kitchen-digitalocean/pull/47)) ([4480aba](https://github.com/test-kitchen/kitchen-digitalocean/commit/4480aba))
* Prepare for release ([a5458a8](https://github.com/test-kitchen/kitchen-digitalocean/commit/a5458a8))

## 0.9.5 / 2015-12-14

- This release fixes the slugs I accidentally broke in 0.9.4.

* fix the slugs I accidentally broke in 0.9.4 ([7ad6f85](https://github.com/test-kitchen/kitchen-digitalocean/commit/7ad6f85))

## 0.9.4 / 2015-12-14

- Update slug mappings.

## 0.9.3 / 2015-08-21

- Show user_data option in debug output.
- Default to 'nologin' when Etc.getlogin doesn't work (windows).

* Add user_data to debug output ([e3bc92a](https://github.com/test-kitchen/kitchen-digitalocean/commit/e3bc92a))
* Fall back to 'nologin' when Etc.Getlogin doesn't exist. Fixes #42 ([ce5fc7d](https://github.com/test-kitchen/kitchen-digitalocean/commit/ce5fc7d))
* Prepare for release ([15e0caa](https://github.com/test-kitchen/kitchen-digitalocean/commit/15e0caa))

## 0.9.2 / 2015-07-20

- [@joonas](https://github.com/joonas) [PR #41] Add the ability to map well-known platforms to slugs

* Prepare for release ([89d7362](https://github.com/test-kitchen/kitchen-digitalocean/commit/89d7362))

## 0.9.1 / 2015-06-19

- [@olivielpeau](https://github.com/olivielpeau) [PR #40] Destroy properly droplets that are still "new"

* Refactor following rubocop ([#39](https://github.com/test-kitchen/kitchen-digitalocean/pull/39)) ([3158d14](https://github.com/test-kitchen/kitchen-digitalocean/commit/3158d14))
* Moar tests ([8008d11](https://github.com/test-kitchen/kitchen-digitalocean/commit/8008d11))
* Add coveralls badge ([e3887a6](https://github.com/test-kitchen/kitchen-digitalocean/commit/e3887a6))
* Lock down gem versions ([f9f7b74](https://github.com/test-kitchen/kitchen-digitalocean/commit/f9f7b74))
* Prepare for release ([19e1307](https://github.com/test-kitchen/kitchen-digitalocean/commit/19e1307))

## 0.9.0 / 2015-04-17

- [@juliandunn](https://github.com/juliandunn) [PR #37] Added the ability to pass user_data into droplet creation.

* Fix failing tests ([67d5b74](https://github.com/test-kitchen/kitchen-digitalocean/commit/67d5b74))
* Fix a couple rubocop warnings ([4795dd9](https://github.com/test-kitchen/kitchen-digitalocean/commit/4795dd9))
* Prepare for 0.9.0 release ([595caec](https://github.com/test-kitchen/kitchen-digitalocean/commit/595caec))

## 0.8.3 / 2014-12-29

- [@RoboticCheese](https://github.com/RoboticCheese) [PR #34] make key IDs always a String

* Fix #34; make key IDs always a String ([#35](https://github.com/test-kitchen/kitchen-digitalocean/pull/35)) ([b22278d](https://github.com/test-kitchen/kitchen-digitalocean/commit/b22278d))
* Prepare for release ([16b8209](https://github.com/test-kitchen/kitchen-digitalocean/commit/16b8209))

## 0.8.2 / 2014-11-09

- Handle API errors more gracefully, closes issue #33.

* Prepare for 0.8.2 release ([c482a02](https://github.com/test-kitchen/kitchen-digitalocean/commit/c482a02))

## 0.8.1 / 2014-10-13

- [@sarkis](https://github.com/sarkis) [PR #32] fix driver config example
- [@sarkis](https://github.com/sarkis) [PR #31] make sure there are no underscores in hostname
- [@sarkis](https://github.com/sarkis) [PR #30] properly split ssh key ids

* Prepare for 0.8.1 release ([ab3f416](https://github.com/test-kitchen/kitchen-digitalocean/commit/ab3f416))
* Use Kernel#loop instead of while true ([d2ee65a](https://github.com/test-kitchen/kitchen-digitalocean/commit/d2ee65a))
* Prepare for release ([6886f38](https://github.com/test-kitchen/kitchen-digitalocean/commit/6886f38))
* Remove cane from default rake task ([df5c141](https://github.com/test-kitchen/kitchen-digitalocean/commit/df5c141))
* Try going back to while true ([1fbed44](https://github.com/test-kitchen/kitchen-digitalocean/commit/1fbed44))
* Prepare for release... again ([6206d80](https://github.com/test-kitchen/kitchen-digitalocean/commit/6206d80))

## 0.8.0 / 2014-8-21

- [@RoboticCheese](https://github.com/RoboticCheese) [PR #25] Sanitize default names, limit to 63 chars

* No longer testing on ruby 1.9.3 ([320aeab](https://github.com/test-kitchen/kitchen-digitalocean/commit/320aeab))
* Disable minimal spec coverage for now... ([2b3737c](https://github.com/test-kitchen/kitchen-digitalocean/commit/2b3737c))
* Coveralls appears to be failing with ruby 2.0 ([3d65d32](https://github.com/test-kitchen/kitchen-digitalocean/commit/3d65d32))
* Update readme ([3b1d6dc](https://github.com/test-kitchen/kitchen-digitalocean/commit/3b1d6dc))
* Prepare for 0.8 release ([db738a3](https://github.com/test-kitchen/kitchen-digitalocean/commit/db738a3))

## 0.8.0.pre1 / 2014-08-21

**_Breaking Changes_**

From this version on the driver uses API V2, the use of image_id, flavor_id, and region_id has been replaced with image, size, region. You can now rely on slugs instead of uses IDs. Please refer to the readme for additional information.

- Upgrade to API V2
- Drop Fog, for [droplet_kit](https://github.com/digitaloceancloud/droplet_kit)

* Upgrade to Digital Ocean API V2. ([dea3810](https://github.com/test-kitchen/kitchen-digitalocean/commit/dea3810))

## 0.7.3 / 2014-08-19

- Add id for New York 3
- Update various other data id's
- [@sample](https://github.com/sample) [PR #23] Fix Debian 7.0 id
- [@skottler](https://github.com/skottler) [PR #22] Update the ID for precise
- [@RoboticCheese](https://github.com/RoboticCheese) [PR #21] Update README to reflect latest platform list

* Update various data id's, and add New York 3 ([10e0df7](https://github.com/test-kitchen/kitchen-digitalocean/commit/10e0df7))
* Prepare for 0.7.3 release ([768660d](https://github.com/test-kitchen/kitchen-digitalocean/commit/768660d))

## 0.7.2 / 2014-07-24

- [@RoboticCheese](https://github.com/RoboticCheese) [PR #20] Update to latest image IDs
- [@ijin](https://github.com/ijin) [PR #19] Update image id list & readme
- [@ishakir](https://github.com/ishakir) [PR #18] Gemfile syntax incorrect
- [@alaa](https://github.com/alaa) [PR #17] Update ssh_key API in the README file

* Fix rubocop warning ([59b0e61](https://github.com/test-kitchen/kitchen-digitalocean/commit/59b0e61))
* Prepare for release ([83c334a](https://github.com/test-kitchen/kitchen-digitalocean/commit/83c334a))

## 0.7.1 / 2014-06-23

- [@RoboticCheese](https://github.com/RoboticCheese) [PR #16] Use the 64-bit CentOS 6.5 image.

* Fix specs for rspec 3 ([6ef7d8a](https://github.com/test-kitchen/kitchen-digitalocean/commit/6ef7d8a))
* Fix rubocop warnings ([a2e8744](https://github.com/test-kitchen/kitchen-digitalocean/commit/a2e8744))
* Prepare for release ([2ed30a2](https://github.com/test-kitchen/kitchen-digitalocean/commit/2ed30a2))

## 0.7.0 / 2014-05-20

- [@zhann](https://github.com/Zhann) [PR #15] Makes hostnames RFC compatible
- [@coderanger](https://github.com/coderanger) [PR #14] New image ID for centos-6.5
- [@coderanger](https://github.com/coderanger) [PR #13] Allow using a correctly name-scoped environment variable for ssh_key_ids

* fix changelog ([b63c1bc](https://github.com/test-kitchen/kitchen-digitalocean/commit/b63c1bc))
* Update readme ([c669096](https://github.com/test-kitchen/kitchen-digitalocean/commit/c669096))
* Prepare for release ([2bc3e16](https://github.com/test-kitchen/kitchen-digitalocean/commit/2bc3e16))
* Update travis.yml to test on ruby 2.1 ([ba02b8c](https://github.com/test-kitchen/kitchen-digitalocean/commit/ba02b8c))
* autocorrect a few rubocop warnings ([38ce87a](https://github.com/test-kitchen/kitchen-digitalocean/commit/38ce87a))

## 0.6.4 / 2014-05-02

- Update image list.

* Prepare for 6.4 release ([701a8de](https://github.com/test-kitchen/kitchen-digitalocean/commit/701a8de))

## 0.6.3 / 2014-04-28

- I messed up the release process for 0.6.2 and yanked it, this is the same as 0.6.2 was meant to be, sorry.

* Prepare for release ([6a0a95f](https://github.com/test-kitchen/kitchen-digitalocean/commit/6a0a95f))

- [@juliandunn](https://github.com/juliandunn) [PR #11] Updated new image IDs from DigitalOcean.

## 0.6.1 / 2014-04-12

- [@juliandunn](https://github.com/juliandunn) [PR #9] DigitalOcean updated some images so the IDs required fixing.

* Prepare changelog for release ([99a5fbd](https://github.com/test-kitchen/kitchen-digitalocean/commit/99a5fbd))

## 0.6.0 / 2014-03-17

- Private Networking is now enabled by default. This only works in select regions.
- The default region was changed to New York 2, so private networking would work by default.

* Enable private networking by default. ([984206e](https://github.com/test-kitchen/kitchen-digitalocean/commit/984206e))
* Prepare for release ([b5bf2c1](https://github.com/test-kitchen/kitchen-digitalocean/commit/b5bf2c1))
* Cleanup some rubocop warnings ([5237168](https://github.com/test-kitchen/kitchen-digitalocean/commit/5237168))

## 0.5.2 / 2014-02-20

- [@lamont-granquist](https://github.com/lamont-granquist) [PR #5] add info on using numeric key ids.
- [@mattwhite](https://github.com/mattwhite) [PR #6] Add Ubuntu 12.04 support.

* Fix gemspec url and description ([80c2f56](https://github.com/test-kitchen/kitchen-digitalocean/commit/80c2f56))
* Prepare for release ([44aee7f](https://github.com/test-kitchen/kitchen-digitalocean/commit/44aee7f))

## 0.5.1 / 2014-02-11

- Add new Singapore 1 region
- Fixed up the readme

* Fix long line ([fda8cf7](https://github.com/test-kitchen/kitchen-digitalocean/commit/fda8cf7))
* Fix typo in README.md ([2c8f34e](https://github.com/test-kitchen/kitchen-digitalocean/commit/2c8f34e))
* Add Singapore 1 as a new region ([363dba9](https://github.com/test-kitchen/kitchen-digitalocean/commit/363dba9))
* Cleanup some typos and old links in the README ([9088ee4](https://github.com/test-kitchen/kitchen-digitalocean/commit/9088ee4))
* Fix badge links ([73a68b1](https://github.com/test-kitchen/kitchen-digitalocean/commit/73a68b1))
* Prepare for release ([d5122cc](https://github.com/test-kitchen/kitchen-digitalocean/commit/d5122cc))

## 0.5.0 / 2013-12-31

- You can alternatively use region and flavor options instead of their _id counter parts. See the readme for more information.

* Oops, forgot to update the Changelog ([49a6712](https://github.com/test-kitchen/kitchen-digitalocean/commit/49a6712))
* Give the option to set flavor and region as a string instead of an id ([866a4fc](https://github.com/test-kitchen/kitchen-digitalocean/commit/866a4fc))
* Update readme for region and flavor options ([559e8d1](https://github.com/test-kitchen/kitchen-digitalocean/commit/559e8d1))
* Fix my words ([9142da7](https://github.com/test-kitchen/kitchen-digitalocean/commit/9142da7))
* Old id lists are no longer needed, use the new flavor and region options ([12642e5](https://github.com/test-kitchen/kitchen-digitalocean/commit/12642e5))
* Prepare for v0.5.0 ([7897701](https://github.com/test-kitchen/kitchen-digitalocean/commit/7897701))
* Fix escaping in readme ([889099c](https://github.com/test-kitchen/kitchen-digitalocean/commit/889099c))

## 0.4.0 / 2013-12-31

- Updated the driver for test kitchen 1.1, fixed some bugs.
- Improved documentation
- It will now read your api key, client id, and ssh key ids, from environment variables if set.
- You can specify the image name rather than the image id

* Bring up to date for test-kitchen 1.x ([81abe61](https://github.com/test-kitchen/kitchen-digitalocean/commit/81abe61))
* Fix github link in readme ([a9372d7](https://github.com/test-kitchen/kitchen-digitalocean/commit/a9372d7))
* Update installation and setup section of the readme ([e8434ea](https://github.com/test-kitchen/kitchen-digitalocean/commit/e8434ea))
* Prepare for v0.4.0 ([ce7de6c](https://github.com/test-kitchen/kitchen-digitalocean/commit/ce7de6c))
* Fix some rubocop warnings ([65c93b3](https://github.com/test-kitchen/kitchen-digitalocean/commit/65c93b3))

## 0.3.1 / 2013-12-29

- [@someara](https://github.com/someara) [PR #2] Relax test-kitchen version dep

* Update changelog for 0.3.1 ([91666c4](https://github.com/test-kitchen/kitchen-digitalocean/commit/91666c4))
* Prepare v0.3.1 release ([3fb5a44](https://github.com/test-kitchen/kitchen-digitalocean/commit/3fb5a44))

## 0.3.0 / 2013-12-12

- Fix deprecation warnings from rspec 3
- Bump test-kitchen dependency to ~> 1.1.0

* Bump test-kitchen to ~&gt; 1.1.0 ([1873cea](https://github.com/test-kitchen/kitchen-digitalocean/commit/1873cea))
* Fix rspec deprecation warnings ([b5b633a](https://github.com/test-kitchen/kitchen-digitalocean/commit/b5b633a))
* Prepare for 0.3.0 release ([4c64cd7](https://github.com/test-kitchen/kitchen-digitalocean/commit/4c64cd7))

## 0.2.1 / 2013-10-31

- Update example tables in the readme
- Fix warning for public_ip_address
- [@dpetzel](https://github.com/dpetzel) [PR #1] flip flavor and image

* Bump test-kitchen and fog versions ([537239f](https://github.com/test-kitchen/kitchen-digitalocean/commit/537239f))
* ip_address =&gt; public_ip_address ([68995f5](https://github.com/test-kitchen/kitchen-digitalocean/commit/68995f5))
* Bump fog version ([d3c7fa7](https://github.com/test-kitchen/kitchen-digitalocean/commit/d3c7fa7))
* Loosing dependencies and switch to rubocop ([12f95ce](https://github.com/test-kitchen/kitchen-digitalocean/commit/12f95ce))
* Fix tests ([7a333fa](https://github.com/test-kitchen/kitchen-digitalocean/commit/7a333fa))
* Update readme tables ([4a6951b](https://github.com/test-kitchen/kitchen-digitalocean/commit/4a6951b))
* Prepare for release ([a9194d5](https://github.com/test-kitchen/kitchen-digitalocean/commit/a9194d5))
* No longer testing on 1.9.2 ([321c02d](https://github.com/test-kitchen/kitchen-digitalocean/commit/321c02d))

## 0.2.0 / 2013-06-19

- Provide debug output for test-kitchen
- Visual feedback during server creation
- Use ruby 1.9 hash syntax
- Bump fog dependency to 1.12

* Add gem version button to readme ([6682a02](https://github.com/test-kitchen/kitchen-digitalocean/commit/6682a02))
* Add some visual indication on the create action ([9b80538](https://github.com/test-kitchen/kitchen-digitalocean/commit/9b80538))
* Provide some debug messages for kitchen ([42d0e8a](https://github.com/test-kitchen/kitchen-digitalocean/commit/42d0e8a))
* Use the ruby 1.9 hash syntax. Upgrade your rubies! ([1c159f6](https://github.com/test-kitchen/kitchen-digitalocean/commit/1c159f6))
* Prepare for 0.2.0 ([4a961aa](https://github.com/test-kitchen/kitchen-digitalocean/commit/4a961aa))

## [0.1.1](https://github.com/test-kitchen/kitchen-digitalocean/compare/0.1.0...0.1.1) (2013-05-11)

* Clean up README.md ([b029bc3](https://github.com/test-kitchen/kitchen-digitalocean/commit/b029bc3))
* Add multi_json as a development dependency ([8a820d7](https://github.com/test-kitchen/kitchen-digitalocean/commit/8a820d7))
* Quote region_id ([de7575d](https://github.com/test-kitchen/kitchen-digitalocean/commit/de7575d))
* Prepare for 0.1.1 ([a0b9a60](https://github.com/test-kitchen/kitchen-digitalocean/commit/a0b9a60))

## 0.1.0 / 2013-05-12

- Initial release

* Initial Import ([b534857](https://github.com/test-kitchen/kitchen-digitalocean/commit/b534857))
* Update README.md ([7808a23](https://github.com/test-kitchen/kitchen-digitalocean/commit/7808a23))
* Fix license name in gemspec ([f4af2e2](https://github.com/test-kitchen/kitchen-digitalocean/commit/f4af2e2))
* Fix line length &gt; 80 ([eef9970](https://github.com/test-kitchen/kitchen-digitalocean/commit/eef9970))
