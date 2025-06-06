# frozen_string_literal: true

require 'rest_client'
require 'json'

Rails.application.configure do
  HOST = ENV.fetch('HOST') do
    "https://#{ENV.fetch('HEROKU_APP_NAME')}.herokuapp.com"
  end

  # Verifies that versions and hashed value of the package contents in the project's package.json
  config.webpacker.check_yarn_integrity = false
  # Settings specified here will take precedence over those in config/application.rb.

  # Code is not reloaded between requests.
  # config.cache_classes = true
  config.enable_reloading = false

  # Eager load code on boot. This eager loads most of Rails and
  # your application in memory, allowing both threaded web servers
  # and those relying on copy on write to perform better.
  # Rake tasks automatically ignore this option for performance.
  config.eager_load = true

  # Full error reports are disabled and caching is turned on.
  config.consider_all_requests_local       = false
  config.action_controller.perform_caching = true

  # Ensures that a master key has been made available in either ENV["RAILS_MASTER_KEY"]
  # or in config/master.key. This key is used to decrypt credentials (and other encrypted files).
  config.require_master_key = true

  # Disable serving static files from the `/public` folder by default since
  # Apache or NGINX already handles this.
  config.public_file_server.enabled = ENV['RAILS_SERVE_STATIC_FILES'].present?

  config.public_file_server.headers = {
    'Cache-Control' => 'public, s-maxage=31536000, max-age=15552000',
    'Expires' => 1.year.from_now.to_formatted_s(:rfc822)
  }

  # Compress JavaScripts and CSS.
  # config.assets.js_compressor = :uglifier
  # config.assets.css_compressor = :sass

  # Do not fallback to assets pipeline if a precompiled asset is missed.
  # config.assets.compile = false

  # `config.assets.precompile` and `config.assets.version` have moved to config/initializers/assets.rb

  # Enable serving of images, stylesheets, and JavaScripts from an asset server.
  # config.action_controller.asset_host = 'http://assets.example.com'

  # Specifies the header that your server uses for sending files.
  # config.action_dispatch.x_sendfile_header = 'X-Sendfile' # for Apache
  # config.action_dispatch.x_sendfile_header = 'X-Accel-Redirect' # for NGINX

  # Store uploaded files on the local file system (see config/storage.yml for options)
  # config.active_storage.service = :clevercloud
  config.active_storage.service = :clevercloud

  # Mount Action Cable outside main process or domain
  host_uri = URI(HOST)
  domain_without_www = host_uri.host.gsub('www.', '')

  config.action_cable.mount_path = nil
  config.action_cable.url = "wss://#{host_uri.host}"
  config.action_cable.allowed_request_origins = [host_uri.to_s]

  # Force all access to the app over SSL, use Strict-Transport-Security, and use secure cookies.
  config.force_ssl = true
  config.ssl_options = { redirect: { status: 302 } }
  # Use the lowest log level to ensure availability of diagnostic information
  # when problems arise.
  config.log_level = :debug

  # Prepend all log lines with the following tags.
  config.log_tags = [:request_id]

  # Use a different cache store in production.

  config.cache_store = :redis_cache_store,
                       { url: ENV.fetch('REDIS_URL'), 'maxmemory-policy': 'allkeys-lfu' }

  # Use a real queuing backend for Active Job (and separate queues per environment)
  # config.active_job.queue_adapter     = :resque
  # config.active_job.queue_name_prefix = "monstage_#{Rails.env}"

  # config.action_mailer.preview_path  = "#{Rails.root}/whatever"
  config.action_mailer.delivery_method = :smtp
  config.action_mailer.perform_caching = false
  config.action_mailer.perform_deliveries = true
  config.action_mailer.show_previews = true
  config.action_mailer.raise_delivery_errors = true
  config.action_mailer.default_url_options = { host: HOST }
  config.action_mailer.preview_paths << "#{Rails.root}/lib/mailer_previews"

  # To choose port read https://help.heroku.com/IR3S6I5X/problem-in-sending-e-mails-through-smtp and then https://fr.mailjet.com/blog/news/port-smtp/
  # and https://stackoverflow.com/questions/26166032/rails-4-netreadtimeout-when-calling-actionmailer
  config.action_mailer.smtp_settings = {
    user_name: ENV['SMTP_USERNAME'],
    password: ENV['SMTP_PASSWORD'],
    domain: ENV['SMTP_DOMAIN'] || 'smtp.mailtrap.io',
    address: ENV['SMTP_ADDRESS'] || 'smtp.mailtrap.io',
    port: ENV['SMTP_PORT'] || '2525',
    authentication: ENV['SMTP_AUTHENTICATION'] || 'cram_md5',
    enable_starttls_auto: true
  }

  # remove following after may 1st 2022

  # response = RestClient.get "https://mailtrap.io/api/v1/inboxes.json?api_token=#{ENV['MAILTRAP_API_TOKEN']}"
  # first_inbox = JSON.parse(response)[0] # get first inbox
  # ActionMailer::Base.smtp_settings = {
  #                                      user_name: first_inbox['username'],
  #                                      password: first_inbox['password'],
  #                                      address: first_inbox['domain'],
  #                                      domain: first_inbox['domain'],
  #                                      port: 587,
  #                                      authentication: :plain
  #                                    }

  # Ignore bad email addresses and do not raise email delivery errors.
  # Set this to true and configure the email server for immediate delivery to raise delivery errors.
  # config.action_mailer.raise_delivery_errors = false
  # ----------------------------
  # Enable locale fallbacks for I18n (makes lookups for any locale fall back to
  # the I18n.default_locale when a translation cannot be found).
  config.i18n.fallbacks = true

  # Send deprecation notices to registered listeners.
  config.active_support.deprecation = :notify

  # Use default logging formatter so that PID and timestamp are not suppressed.
  config.log_formatter = ::Logger::Formatter.new

  # Use a different logger for distributed setups.
  # require 'syslog/logger'
  # config.logger = ActiveSupport::TaggedLogging.new(Syslog::Logger.new 'app-name')
  logger           = ActiveSupport::Logger.new(STDOUT)
  logger.formatter = config.log_formatter
  config.logger    = ActiveSupport::TaggedLogging.new(logger)

  # Do not dump schema after migrations.
  config.active_record.dump_schema_after_migration = false
end
