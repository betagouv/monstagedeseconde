module JwtAuth
  SECRET_KEY = ENV['JWT_SECRET_KEY']
  ALGORITHM  = 'HS256'

  def self.encode(payload, exp = 24.hours.from_now)
    payload[:exp] = exp.to_i
    JWT.encode(payload, SECRET_KEY, ALGORITHM)
  end

  def self.decode(token)
    decoded, _header = JWT.decode(
      token,
      SECRET_KEY,
      true,
      algorithm: ALGORITHM
    )
    HashWithIndifferentAccess.new(decoded)
  rescue JWT::DecodeError
    nil
  end
end
