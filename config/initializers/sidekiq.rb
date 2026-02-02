redis_config = { url: ENV['REDIS_URL'] }

Sidekiq.configure_server do |config|
 config.redis = redis_config
 config[:average_scheduled_poll_interval] = 5
end

Sidekiq.configure_client do |config|
 config.redis = redis_config
end
