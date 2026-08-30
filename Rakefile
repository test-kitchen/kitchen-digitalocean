# frozen_string_literal: true

require "bundler/gem_tasks"

require "rspec/core/rake_task"

desc "Run the unit tests"
RSpec::Core::RakeTask.new(:test)

begin
  require "cookstyle/chefstyle"
  require "rubocop/rake_task"

  RuboCop::RakeTask.new(:style) do |task|
    task.options += ["--display-cop-names", "--no-color"]
  end
rescue LoadError
  puts "cookstyle/chefstyle is not available. (sudo) gem install cookstyle to do style checking."
end

# Documentation tasks are intentionally kept out of the `default` task and out
# of CI: a missing YARD tag should never turn a pull request red.
begin
  require "yard"

  YARD::Rake::YardocTask.new(:yard) do |task|
    task.files = ["lib/**/*.rb"]
    task.options = ["--output-dir", "doc"]
    task.stats_options = ["--list-undoc"]
  end

  namespace :yard do
    desc "Report documentation coverage without writing the docs"
    task :stats do
      sh "yard stats --list-undoc"
    end

    desc "Serve the generated documentation at http://localhost:8808"
    task :server do
      sh "yard server --reload"
    end
  end

  desc "Generate the YARD documentation (alias for `yard`)"
  task doc: :yard
rescue LoadError
  desc "Generate the YARD documentation (unavailable)"
  task :yard do
    abort "yard is not available. Run `bundle install --with development` or `gem install yard`."
  end

  task doc: :yard
end

task default: %i{test style}
