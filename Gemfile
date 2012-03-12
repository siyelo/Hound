source 'http://rubygems.org'

gem 'awesome_nested_set'
gem 'chronic'
gem 'devise'
gem "devise_invitable"
gem 'diffy'
gem 'foreman'
gem 'gitploy'
gem 'haml', '~> 3.1.4'
gem 'jquery-rails'
gem 'mail'
gem 'pg'
gem 'rails', '3.2.0'
gem 'resque', '>= 1.20.0'
gem 'resque-scheduler', require: "resque/server"
gem 'therubyracer'
gem 'tinymce-rails'
gem 'unicorn'
# Gems used only for assets and not required
# in production environments by default.

group :assets do
  gem 'sass-rails', "  ~> 3.2.3"
  gem 'coffee-rails', "~> 3.2.1"
  gem 'uglifier', '>= 1.0.3'
end

group :development do
  gem "rspec-rails"
  gem 'guard-spork'
  gem 'mailcatcher'
  gem 'annotate', '~> 2.4.1.beta'
end

group :test do
  # Pretty printed test output
  gem 'turn', '0.8.2', :require => false
  gem "factory_girl_rails"
  gem "guard-rspec"
  gem 'shoulda-matchers'
  gem 'database_cleaner'
  gem 'steak'
  gem 'email_spec'
  gem 'resque_spec'
  gem 'rspec-mocks'
  gem 'capybara-webkit'
  gem 'headless'
  gem 'launchy'
end

group :development, :test do
  ### http://stackoverflow.com/questions/8251349/ruby-threadptr-data-type-error
  gem 'linecache19', :git => 'git://github.com/mark-moseley/linecache'
  gem 'ruby-debug-base19x', '~> 0.11.30.pre10'
  gem 'ruby-debug19'
end
