source 'http://rubygems.org'

gem "airbrake"
gem 'chronic'
gem 'devise'
gem "devise_invitable"
gem 'foreman'
gem 'gitploy'
gem 'haml', '~> 3.1.4'
gem 'jquery-rails'
gem 'mail'
gem 'pg'
gem 'rails', '3.2.2'
gem 'resque', '>= 1.20.0'
gem 'resque-scheduler', require: "resque/server"
gem 'tinymce-rails'
gem 'unicorn'
gem 'haml-rails'
gem 'html5-rails'

group :assets do
  gem 'sass-rails', "  ~> 3.2.3"
  gem 'coffee-rails', "~> 3.2.1"
  gem 'uglifier', '>= 1.0.3'
  gem 'compass-rails'
  gem 'compass-h5bp'
end

group :development do
  gem 'annotate', '~> 2.4.1.beta'
  gem 'guard-spork'
  gem "rspec-rails"
  gem 'mailcatcher'
end

group :test do
  # Pretty printed test output
  gem 'capybara-webkit'
  gem 'database_cleaner'
  gem "factory_girl_rails"
  gem "guard-rspec"
  gem 'headless'
  gem 'launchy'
  gem 'email_spec'
  gem 'resque_spec'
  gem 'rspec-mocks'
  gem 'shoulda-matchers'
  gem 'turn', '0.8.2', :require => false
  gem 'timecop'
end

group :development, :test do
  gem 'guard-coffeescript'
  gem "guard-jasmine"
  gem 'jasmine'
  gem "linecache19", "~> 0.5.13"
  gem 'ruby-debug19'
  gem 'ruby-debug-base19x'
  gem 'interactive_editor'
end
