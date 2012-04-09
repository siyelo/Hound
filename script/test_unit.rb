require_relative '../lib/spec_finder'
require_relative '../lib/script_helper'

include ScriptHelper

cmd = "rspec #{SpecFinder::unit_test_files.flatten.join(' ')}"
run(cmd)


