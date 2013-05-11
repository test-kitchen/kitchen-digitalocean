require 'bundler/gem_tasks'
require 'tailor/rake_task'
require 'cane/rake_task'
require 'rspec/core/rake_task'

desc 'Run Cane to check quality metrics'
Cane::RakeTask.new

desc 'Run Tailor to lint check code'
Tailor::RakeTask.new do |task|
  task.file_set '**/**/*.rb'
end

desc 'Display LOC stats'
task :loc do
  puts "\n## LOC Stats"
  sh 'countloc -r lib/kitchen'
end

desc 'Run RSpec unit tests'
RSpec::Core::RakeTask.new(:spec)

task :default => [ :cane, :tailor, :loc, :spec ]

# vim: ai et ts=2 sts=2 sw=2 ft=ruby fdm=marker
