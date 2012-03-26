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
  run_or_die "rake test"
end

# http://blog.kabisa.nl/2010/05/24/headless-cucumbers-and-capybaras-with-selenium-and-hudson/
# and http://markgandolfo.com/2010/07/01/hudson-ci-server-running-cucumber-in-headless-mode-xvfb
# def setup_x_server
#   ENV['RAILS_ENV'] = 'test'
#   ENV['DISPLAY'] = ":99"
#   run "/etc/init.d/xvfb start"
# end

# def teardown_x_server
#   run "/etc/init.d/xvfb stop"
# end

# main
run_or_die "bundle install"
setup_db
#setup_x_server
run_specs
#teardown_x_server
run_or_die "rake clean"

