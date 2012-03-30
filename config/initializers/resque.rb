require 'resque_scheduler'
require 'resque/failure/multiple'
require 'resque/failure/airbrake'
require 'resque/failure/redis'

Resque::Failure::Airbrake.configure do |config|
  config.api_key = '5e5cd1f814ba7bbe61aa9a756b1b7f56'
  config.secure = true
end
Resque::Failure::Multiple.classes = [Resque::Failure::Redis, Resque::Failure::Airbrake]
Resque::Failure.backend = Resque::Failure::Multiple

Resque.schedule = YAML.load_file("#{Rails.root}/config/resque_schedule.yml")
