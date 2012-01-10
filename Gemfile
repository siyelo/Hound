source 'http://rubygems.org'

gem 'rails', '3.1.3'
gem 'sqlite3'
gem 'therubyracer'
gem 'resque-scheduler', :require => "resque/server"
gem 'mail'
gem 'chronic'
gem 'jquery-rails'

# Gems used only for assets and not required
# in production environments by default.
group :assets do
  gem 'sass-rails',   '~> 3.1.5'
  gem 'coffee-rails', '~> 3.1.1'
  gem 'uglifier', '>= 1.0.3'
end

group :development do
  gem "rspec-rails"
  gem 'guard-spork'
  gem 'ruby-debug19'
end

group :test do
  # Pretty printed test output
  gem 'turn', '0.8.2', :require => false
  gem "rspec-rails"
  gem "factory_girl_rails"
  gem "capybara"
  gem "guard-rspec"
  gem 'shoulda'
  gem 'timecop'
end
