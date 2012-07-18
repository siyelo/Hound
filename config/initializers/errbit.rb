Airbrake.configure do |config|
  config.api_key = 'cad664dadbc7803ba5c696e4238aa502'
  config.host    = 'errbit.siyelo.com'
  config.port    = 80
  config.secure	 = config.port == 443
end
