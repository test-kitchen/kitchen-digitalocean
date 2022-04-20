require "bundler/gem_tasks"
require "rspec/core/rake_task"

begin
  require "chefstyle"
  require "rubocop/rake_task"
  RuboCop::RakeTask.new(:style) do |task|
    task.options += ["--display-cop-names", "--no-color"]
  end
rescue LoadError
  puts "chefstyle is not available. (sudo) gem install chefstyle to do style checking."
end

desc "Display LOC stats"
task :loc do
  puts "\n## LOC Stats"
  sh "countloc -r lib/kitchen"
end

desc "Run RSpec unit tests"
RSpec::Core::RakeTask.new(:spec)

task default: %i{style loc spec}

# vim: ai et ts=2 sts=2 sw=2 ft=ruby fdm=marker
