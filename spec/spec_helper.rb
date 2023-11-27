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

require "rspec"
require "webmock/rspec"

WebMock.disable_net_connect!(allow_localhost: true)

require_relative "../lib/kitchen/driver/digitalocean"

def create
  File.read(File.join(File.dirname(__FILE__), "mocks", "create.txt"))
end

def delete
  File.read(File.join(File.dirname(__FILE__), "mocks", "delete.txt"))
end

def auth_error
  File.read(File.join(File.dirname(__FILE__), "mocks", "auth_error.txt"))
end

def find
  File.read(File.join(File.dirname(__FILE__), "mocks", "find.txt"))
end

# vim: ai et ts=2 sts=2 sw=2 ft=ruby
