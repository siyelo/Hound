# Load the rails application
require File.expand_path('../application', __FILE__)

# Initialize the rails application
Hound::Application.initialize!

Mongoid.load!("config/mongoid.yml")
