require 'rake/testtask'
require 'rspec/core/rake_task'
require 'spec_finder'
require 'script_helper'

include ScriptHelper

namespace 'test' do |ns|
  desc "Run unit tests"
  task :unit do
    run 'ruby script/test_unit.rb'
  end

  desc "Run integration tests"
  RSpec::Core::RakeTask.new('integration') do |t|
    t.pattern = SpecFinder::integration_test_files
  end
end

# Clear out the default Rails dependencies
Rake::Task[:test].clear
desc "Run all tests"
task 'test' => %w[test:unit test:integration]

#override rspec default (:spec)
Rake::Task[:default].clear
desc 'Default: run unit tests.'
task :default => :test
