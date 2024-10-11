# frozen_string_literal: true

source 'https://rubygems.org'
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby File.read('.ruby-version').strip

# fwk/server
gem 'actionpack', '>= 6.1.3.2'
gem 'puma'
gem 'rails', '~> 7.1.3'
# db
gem 'pg'
gem 'rake'

# pg extension for geo queries
# wait for : https://github.com/rgeo/activerecord-postgis-adapter/tree/ar61 to be merge into master
gem 'activerecord-postgis-adapter', '>= 8.0.1'

# don't bump until fixed, https://github.com/Casecommons/pg_search/issues/446
gem 'pg_search', '2.3.2' # pg search for autocomplete
gem 'prawn'
gem 'prawn-styled-text'
gem 'prawn-table'

# front end
gem 'browser'
gem 'caxlsx_rails'
gem 'inline_svg'
gem 'react_on_rails'
gem 'slim-rails'
gem 'split', require: 'split/dashboard'
gem 'uglifier'
gem 'view_component'
gem 'webpacker'

# background jobs
gem 'redis-namespace' # plug redis queues on same instance for prod/staging
gem 'sidekiq', '~> 6.5', '>= 6.1.2'
# Use Redis for Action Cable
gem 'aws-sdk-s3', require: false
gem 'redis', '~> 4.0'

# admin
# gem 'rails_admin', '~> 3.2.0'
# gem 'rails_admin_aasm'
# gem 'rails_admin-i18n'

# instrumentation
gem 'geocoder'
gem 'lograge'
gem 'ovh-rest'
gem 'sentry-rails'
gem 'sentry-ruby'
gem 'sentry-sidekiq'
# TODO: remove bitly
gem 'bitly'
gem 'mime-types'
gem 'prismic.io', require: 'prismic'

# acl
gem 'cancancan'
gem 'devise'
gem 'devise-i18n'

# model/utils
gem 'aasm'
gem 'discard'
gem 'kaminari'
# model/validators
gem 'email_inquire'
gem 'jwt'
gem 'validates_zipcode'

# dev utils
gem 'bootsnap', require: false
gem 'dalli'
gem 'tzinfo-data', platforms: %i[mingw mswin x64_mingw jruby]

group :development, :test do
  gem 'debug'
  gem 'dotenv-rails', require: 'dotenv/load'
  # Call 'byebug' anywhere in the code to stop execution and get a debugger console
  gem 'byebug', platforms: %i[mri mingw x64_mingw]
  gem 'pry-byebug'
end

group :development do
  gem 'foreman'
  gem 'rubocop'
  # Access an interactive console on exception pages or by calling 'console' anywhere in the code.
  gem 'bullet'
  gem 'listen'
  # Spring speeds up development by keeping your application running in the
  # background. Read more: https://github.com/rails/spring
  gem 'activerecord-explain-analyze'
  gem 'ffi-rzmq'
  gem 'jupyter_on_rails'
  gem 'letter_opener'
  gem 'spring', '3.0.0'
end

group :test do
  # External api calls isolation
  gem 'webmock'
  # Adds support for Capybara system testing and selenium driver
  gem 'capybara'
  gem 'minitest-reporters'
  gem 'minitest-retry'
  gem 'selenium-webdriver'
  # Easy installation and use of chromedriver to run system tests with Chrome
  gem 'capybara-screenshot'
  gem 'minitest-stub_any_instance'
  gem 'rails-controller-testing'
  gem 'webdrivers'
end

group :review do
  gem 'rest-client' # used by mailtrap for review apps
end

group :test, :development, :review do
  gem 'factory_bot_rails'
  gem 'ffaker'
end
