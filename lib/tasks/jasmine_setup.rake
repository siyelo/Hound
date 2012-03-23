# Jasmine & Rails 3.1 asset pipeline don't play well together; a workaround
# source: https://gist.github.com/1895021

task :copy_jquery_files do
  # Jasmine doesn't work with the asset pipeline; therefore we copy the jquery
  # files manually.
  spec = Gem::Specification.find_by_name("jquery-rails")
  jquery_dir = Pathname.new(Gem.dir) +
                "gems" +
                "#{spec.name}-#{spec.version}" +
                "vendor" +
                "assets" +
                "javascripts"
  jquery_file    = jquery_dir + "jquery.min.js"
  jquery_ui_file = jquery_dir + "jquery-ui.min.js"

  destination_dir = Pathname.new(Rails.root) + "spec" + "javascripts" + "tmp_helpers"
  rm_rf destination_dir
  mkdir destination_dir
  cp jquery_file, destination_dir
  cp jquery_ui_file, destination_dir
end

task :"jasmine:require" => [:copy_jquery_files]

