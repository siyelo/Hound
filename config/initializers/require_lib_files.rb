### This is a hack of sorts because config.autoload_paths doesn't seem to be working
Dir[Rails.root + 'lib/**/*.rb'].each do |file|
  require file
end
