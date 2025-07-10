#
require 'bundler/setup'
require 'rack/reloader'
require 'flipper/ui'
require 'flipper/adapters/active_record'
require 'flipper/adapters/active_support_cache_store'


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

# This setup is primarily for first deployment, because consequently
# we can add new features from the Web UI. However when the new DB is created
# this will immediately migrate the default features to be controlled.
#

def setup_features(features)
  existing = Flipper.preload_all.map { _1.name.to_sym }
  missing = features - existing

  missing.each do |feature|
    # Feature is disabled by default
    Flipper.add(feature.to_s)
  end
end

# A list of features to be deployed on first push
features = [
  :maintenance_mode,
]

def database_exists?
  ActiveRecord::Base.connection
  true
rescue ActiveRecord::ConnectionNotEstablished, ActiveRecord::NoDatabaseError, PG::ConnectionBad
  false
end

Flipper.configure do |config|
  config.adapter do
    Flipper::Adapters::ActiveSupportCacheStore.new(
      Flipper::Adapters::ActiveRecord.new,
      ActiveSupport::Cache::MemoryStore.new,
      10.seconds
    )
  end
end

ActiveSupport.on_load(:active_record) do
  if database_exists? && ActiveRecord::Base.connection.data_source_exists?('flipper_features')
    setup_features(features)
  end
end

Rails.application.configure do
  config.flipper.actor_limit = 500 # default is 100 but hide_instructeur_email feature has ~478
  # don't preload features for /assets/* but do for everything else
  config.flipper.preload = -> (request) { !request.path.start_with?('/assets/', 'app/front_assets/', 'app/javascript',  '/ping') }
  config.flipper.strict = Rails.env.development?
end

# groups registration
# Flipper.register(:admins) { |actor| actor.god? }
# Flipper.register(:students) { |actor| actor.student? }
# Flipper.register(:school_management) { |actor| actor.school_management? }
# Flipper.enable_group(:secrets, :admins)

# Flipper.enable :holidays_maintenance
