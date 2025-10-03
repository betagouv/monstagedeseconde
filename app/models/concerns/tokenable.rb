module Tokenable
  extend ActiveSupport::Concern

  def generate_token
    return if access_token.present?

    loop do
      self.access_token = SecureRandom.hex(10)
      break unless self.class.exists?(access_token: access_token)
    end
    save
  end
end