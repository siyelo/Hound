Airbrake.configure do |config|
  config.api_key = ENV['ERRBIT_KEY']
  config.host    = 'errbit.siyelo.com'
  config.port    = 80
  config.secure	 = config.port == 443
end
