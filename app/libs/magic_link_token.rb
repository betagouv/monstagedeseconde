module MagicLinkToken
  TTL = 15.minutes
  REDIS_PREFIX = 'magic_link:jti:'.freeze

  def self.register(jti)
    $redis.set(redis_key(jti), '1', ex: TTL.to_i)
  end

  def self.consume(jti)
    return false if jti.blank?

    $redis.del(redis_key(jti)) == 1
  end

  def self.redis_key(jti)
    "#{REDIS_PREFIX}#{jti}"
  end
end
