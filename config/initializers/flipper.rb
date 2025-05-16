#
require 'bundler/setup'
require 'rack/reloader'
require 'flipper/ui'
require 'flipper/adapters/active_record'

Flipper.configure do |config|
  config.adapter { Flipper::Adapters::ActiveRecord.new }
end

#  banner
Flipper::UI.configure do |config|
  if Rails.env.production?
    config.banner_class = 'danger'
    config.banner_text = 'Production Environment'
  elsif Rails.env.staging?
    config.banner_class = 'warning'
    config.banner_text = 'Staging Environment' if Rails.env.staging?
  elsif Rails.env.development?
    config.banner_class = 'info'
    config.banner_text = 'Development Environment' if Rails.env.development?
  else
    config.banner_class = 'info'
    config.banner_text = 'Review Environment'
  end

  # actors
  config.actor_names_source = lambda { |actor_ids|
    # Lookup actor_ids here and return hash, e.g.
    {
      'User;1' => 'Dr. Paul Rhoades'

    }
  }
  config.feature_creation_enabled = true
  config.feature_removal_enabled = true
  config.cloud_recommendation = true
  config.confirm_fully_enable = true
  config.read_only = false
end

# groups registration
# Flipper.register(:admins) { |actor| actor.god? }
# Flipper.register(:students) { |actor| actor.student? }
# Flipper.register(:school_management) { |actor| actor.school_management? }
# Flipper.enable_group(:secrets, :admins)

# Flipper.enable :holidays_maintenance
