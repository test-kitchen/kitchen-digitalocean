require 'bundler/gem_tasks'
require 'rubocop/rake_task'
require 'cane/rake_task'
require 'rspec/core/rake_task'

desc 'Run Cane to check quality metrics'
Cane::RakeTask.new

desc 'Run RuboCop on the lib directory'
RuboCop::RakeTask.new(:rubocop) do |task|
  task.patterns = ['lib/**/*.rb']
  # don't abort rake on failure
  task.fail_on_error = false
end

desc 'Display LOC stats'
task :loc do
  puts "\n## LOC Stats"
  sh 'countloc -r lib/kitchen'
end

desc 'Run RSpec unit tests'
RSpec::Core::RakeTask.new(:spec)

task default: [:rubocop, :loc, :spec]

# vim: ai et ts=2 sts=2 sw=2 ft=ruby fdm=marker
