require 'rake/testtask'
require 'rspec/core/rake_task'

namespace 'test' do |ns|
  test_files = FileList['spec/**/*_spec.rb']
  integration_test_files = FileList['spec/**/*_integration_spec.rb']
  acceptance_test_files = FileList['spec/**/*_acceptance_spec.rb'] + FileList['spec/**/*_functional_spec.rb']
  unit_test_files = test_files - integration_test_files - acceptance_test_files

  desc "Run unit tests"
  RSpec::Core::RakeTask.new('unit') do |t|
    t.pattern = unit_test_files
    t.fail_on_error = false
  end


  desc "Run integration tests"
  RSpec::Core::RakeTask.new('integration') do |t|
    t.pattern = integration_test_files
    t.fail_on_error = false
  end

  desc "Run acceptance/functional tests"
  RSpec::Core::RakeTask.new('acceptance') do |t|
    t.pattern = acceptance_test_files
    t.fail_on_error = false
  end
end

# Clear out the default Rails dependencies
Rake::Task['test'].clear
desc "Run all tests"
task 'test' => %w[test:unit test:integration test:acceptance jasmine:ci]

