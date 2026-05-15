module TwoFactorAuthenticatable
  extend ActiveSupport::Concern

  TOTP_ISSUER  = '1élève1stage'.freeze
  TOTP_DRIFT_S = 30

  def otp_enrolled?
    otp_secret.present?
  end

  def assign_new_otp_secret!
    update!(otp_secret: ROTP::Base32.random)
  end

  def reset_otp_enrollment!
    update!(otp_secret: nil, otp_last_used_at: nil)
  end

  def verify_otp(code)
    return false if code.blank? || otp_secret.blank?

    timestamp = totp.verify(code.to_s.gsub(/\s+/, ''), drift_behind: TOTP_DRIFT_S, drift_ahead: TOTP_DRIFT_S, after: otp_last_used_at)
    return false unless timestamp

    update!(otp_last_used_at: Time.at(timestamp))
    true
  end

  def otp_provisioning_uri
    totp.provisioning_uri(email)
  end

  private

  def totp
    ROTP::TOTP.new(otp_secret, issuer: TOTP_ISSUER)
  end
end
