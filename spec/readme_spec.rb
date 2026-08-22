# frozen_string_literal: true

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

require "spec_helper"

# The README is the first thing a new user reads, so the tables in it are
# treated as part of the public interface and checked against the code.
RSpec.describe "README.md" do
  let(:readme) { File.read(File.expand_path("../README.md", __dir__)) }

  describe "the platform slug table" do
    subject(:documented_slugs) { parse_table("Platform name", "Image slug") }

    let(:actual_slugs) { Kitchen::Driver::Digitalocean::PLATFORM_SLUG_MAP }

    it "documents every platform the driver maps" do
      expect(documented_slugs.keys).to match_array(actual_slugs.keys)
    end

    it "documents the correct slug for every platform" do
      expect(documented_slugs).to eq(actual_slugs)
    end

    it "lists the platforms in the same order as the code" do
      expect(documented_slugs.keys).to eq(actual_slugs.keys)
    end
  end

  describe "the configuration table" do
    subject(:documented_settings) { parse_table("Setting", "Default").keys }

    # `pre_create_command` is inherited from Kitchen::Driver::Base and is
    # documented by Test Kitchen itself, not here.
    let(:inherited_settings) { %w{pre_create_command} }

    let(:actual_settings) do
      driver = build_driver
      driver.diagnose.keys.map(&:to_s) - inherited_settings
    end

    it "documents every setting the driver exposes" do
      expect(documented_settings).to match_array(actual_settings)
    end
  end

  # Extracts a two column markdown table, identified by its header cells.
  #
  # @param first_header [String] text of the first header cell
  # @param second_header [String] text of the second header cell
  # @return [Hash{String=>String}] the table rows, backticks stripped
  def parse_table(first_header, second_header)
    header = /^\|\s*#{Regexp.escape(first_header)}\s*\|\s*#{Regexp.escape(second_header)}\s*\|/
    start = readme.lines.index { |line| line.match?(header) }
    raise "no #{first_header}/#{second_header} table in README.md" if start.nil?

    rows = readme.lines[(start + 2)..].take_while { |line| line.start_with?("|") }

    rows.to_h do |row|
      cells = row.split("|").map(&:strip).reject(&:empty?)
      [cells[0].delete("`"), cells[1].delete("`")]
    end
  end
end
