# frozen_string_literal: true

source "https://rubygems.org"
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby File.read(".ruby-version").strip

# fwk/server
gem "actionpack", ">= 6.1.3.2"
gem "puma"
gem "rails", "~> 7.2"
gem "mutex_m"
# db
gem "pg"
gem "rack", ">= 3.0"
gem "rake"

# pg extension for geo queries
# wait for : https://github.com/rgeo/activerecord-postgis-adapter/tree/ar61 to be merge into master
gem "activerecord-postgis-adapter", ">= 8.0.1"

# don't bump until fixed, https://github.com/Casecommons/pg_search/issues/446
gem "pg_search", "2.3.2" # pg search for autocomplete

# front end
gem "browser"
gem "caxlsx_rails"
gem "dsfr-view-components"
gem "inline_svg"
gem "react_on_rails", "14.2.1"
gem "slim-rails"
gem "split", require: "split/dashboard"
gem "uglifier"
gem "view_component"
gem "webpacker"
# -- pdf
gem "prawn"
gem "prawn-styled-text"
gem "prawn-table"

# background jobs
gem "sidekiq", "< 8"
gem "connection_pool" , "< 3.0"
# Use Redis for Action Cable
gem "aws-sdk-s3", require: false
gem "redis", "~> 4.0"

# admin
gem "rails_admin", "~> 3.0"
gem "rails_admin_aasm"
gem "rails_admin-i18n"

# instrumentation
gem "flipper"
gem "flipper-active_record"
gem "flipper-active_support_cache_store"
gem "flipper-ui"
gem "geocoder"
gem "lograge"
gem "ovh-rest"
gem "sentry-rails"
gem "sentry-ruby"
gem "sentry-sidekiq"
# TODO: remove bitly
gem "bitly"
gem "mime-types"
gem "prismic.io", require: "prismic"

# acl
gem "cancancan"
gem "devise"
gem "devise-i18n"

# model/utils
gem "aasm"
gem "discard"
gem "kaminari"
# model/validators
gem "email_inquire"
gem "jwt"
gem "validates_zipcode"

# dev utils
gem "bootsnap", require: false
gem "dalli"
gem "dotenv-rails", require: "dotenv/load"
gem "tzinfo-data", platforms: %i[windows jruby]

# Active Storage validations
gem "active_storage_validations"

# Pour le traitement des images
gem "image_processing", "~> 1.2"
gem "mini_magick"

# temporary
gem "fiddle"
gem "ostruct"

group :development, :test do
  gem "debug"
  gem "stringio", "3.1.7"
  # Call 'byebug' anywhere in the code to stop execution and get a debugger console
  gem "byebug", platforms: %i[windows jruby]
  gem "pry-byebug"
end

group :development do
  gem "foreman"
  gem "rubocop"
  # Access an interactive console on exception pages or by calling 'console' anywhere in the code.
  gem "bullet"
  gem "listen"
  # Spring speeds up development by keeping your application running in the
  # background. Read more: https://github.com/rails/spring
  gem "activerecord-explain-analyze"
  gem "ffi-rzmq"
  gem "jupyter_on_rails"
  gem "letter_opener_web"
  gem "spring", "3.0.0"
end

group :test do
  # External api calls isolation
  gem "webmock"
  # Adds support for Capybara system testing and selenium driver
  gem "capybara"
  gem "minitest-fail-fast"
  gem "minitest-reporters"
  gem "minitest-retry"
  gem "selenium-webdriver", ">= 4.8"
  # Easy installation and use of chromedriver to run system tests with Chrome
  gem "capybara-screenshot"
  gem "minitest-stub_any_instance"
  gem "minitest-stub-const"
  gem "rails-controller-testing"
  gem "webdrivers"
end

group :review do
  gem "rest-client" # used by mailtrap for review apps
end

group :test, :development, :review do
  gem "factory_bot_rails"
  gem "ffaker"
end
