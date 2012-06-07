#!/usr/bin/env ruby

# CI server test script
#   Runs all specs and cukes

# Usage:
#  !/bin/bash
#  source /var/lib/jenkins/.rvm/scripts/rvm
#  source $WORKSPACE/.rvmrc
#  $WORKSPACE/script/ci/ci.rb
#

require File.join(File.dirname(__FILE__), '../../lib/', 'script_helper')
include ScriptHelper

WORKSPACE=ENV['WORKSPACE'] || "../../"

def bundle_install
end

def setup_db
  run "cp #{WORKSPACE}/config/database.yml.pg #{WORKSPACE}/config/database.yml"
end

def setup_specs
  ENV['RAILS_ENV'] = 'test'
  run_or_die "rake setup_quick --trace RAILS_ENV=test"
end

def run_specs
  setup_specs
  ENV['DISPLAY'] = ":0.0"
  run_or_die "xvfb-run bundle exec rspec spec"
end

# main
run_or_die "bundle install"
setup_db
run_specs
run_or_die "rake clean"

