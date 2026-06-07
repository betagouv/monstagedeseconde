redis_config = { url: ENV['REDIS_URL'] }
# Heroku Redis impose TLS (URL en rediss://) avec un certificat auto-signé : on désactive
# la vérification du certificat, mais uniquement dans ce cas (inoffensif en local / non-TLS).
if ENV['REDIS_URL'].to_s.start_with?('rediss://')
  redis_config[:ssl_params] = { verify_mode: OpenSSL::SSL::VERIFY_NONE }
end

Sidekiq.configure_server do |config|
 config.redis = redis_config
 config[:average_scheduled_poll_interval] = 5
end

Sidekiq.configure_client do |config|
 config.redis = redis_config
end
