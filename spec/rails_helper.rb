# spec/rails_helper.rb
require 'spec_helper'
ENV['RAILS_ENV'] ||= 'test'
require_relative '../config/environment'
abort("The Rails environment is running in production mode!") if Rails.env.production?
require 'rspec/rails'
require 'swagger_helper'

# Minimal RSpec config for rswag only
RSpec.configure do |config|
  config.infer_spec_type_from_file_location!
  config.filter_rails_from_backtrace!
  
  # Only run request specs (for API docs)
  config.pattern = 'spec/requests/**/*_spec.rb'
end