# Encoding: UTF-8

require 'bundler/setup'
require 'rubocop/rake_task'
require 'cane/rake_task'
require 'rspec/core/rake_task'

Cane::RakeTask.new

RuboCop::RakeTask.new do |task|
  task.patterns = %w(**/*.rb)
end

desc 'Display LOC stats'
task :loc do
  puts "\n## LOC Stats"
  sh 'countloc -r lib/kitchen'
end

RSpec::Core::RakeTask.new(:spec)

task default: [:cane, :rubocop, :loc, :spec]
