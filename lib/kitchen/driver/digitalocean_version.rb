# frozen_string_literal: true

#
# Author:: Greg Fitzgerald (<greg@gregf.org>)
#
# Copyright (C) 2013, Greg Fitzgerald
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#    http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

module Kitchen
  # Namespace for Test Kitchen driver plugins.
  module Driver
    # Version of the kitchen-digitalocean gem.
    #
    # Kept in its own file so the gemspec can read it without loading the
    # driver, and so `release-please` has a single line to bump.
    #
    # @return [String] a semantic version string
    DIGITALOCEAN_VERSION = "0.17.0"
  end
end

# vim: ai et ts=2 sts=2 sw=2 ft=ruby
