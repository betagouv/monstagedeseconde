# frozen_string_literal: true

require 'test_helper'

class TwoFactorChallengesControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  setup do
    @admin = create(:god, password: 'Password123!', password_confirmation: 'Password123!')
  end

  test 'GET without pending 2FA redirects to login' do
    get two_factor_challenge_path
    assert_redirected_to new_user_session_path
    assert_equal 'Session expirée. Veuillez vous reconnecter.', flash[:alert]
  end

  test 'GET with pending 2FA shows enrollment when user has no secret' do
    begin_pending(@admin)
    get two_factor_challenge_path

    assert_response :success
    assert_match 'Activation de la double authentification', response.body
    assert @admin.reload.otp_enrolled?, 'secret should be generated on enrollment view'
  end

  test 'POST with valid OTP signs in the pending user' do
    @admin.assign_new_otp_secret!
    begin_pending(@admin)

    code = ROTP::TOTP.new(@admin.otp_secret).now
    post two_factor_challenge_path, params: { otp_code: code }

    follow_redirect!
    assert_match 'Connexion réussie', response.body
  end

  test 'POST with invalid OTP is rejected' do
    @admin.assign_new_otp_secret!
    begin_pending(@admin)

    post two_factor_challenge_path, params: { otp_code: '000000' }

    assert_response :unprocessable_entity
    assert_match 'Code invalide ou expiré.', response.body
  end

  test 'OTP cannot be replayed within the same window' do
    @admin.assign_new_otp_secret!
    code = ROTP::TOTP.new(@admin.otp_secret).now

    assert @admin.verify_otp(code), 'first verification should succeed'
    assert_not @admin.reload.verify_otp(code), 'second verification with the same code must fail'
  end

  private

  def begin_pending(user)
    jti = SecureRandom.uuid
    MagicLinkToken.register(jti)
    token = JwtAuth.encode({ user_id: user.id, jti: jti }, 15.minutes.from_now)
    get magic_link_path(token: token)
    assert_redirected_to two_factor_challenge_path
  end
end
