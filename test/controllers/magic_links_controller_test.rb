# frozen_string_literal: true

require 'test_helper'

class MagicLinksControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  test 'magic link redirects God to TOTP challenge instead of signing in directly' do
    @admin = create(:god, password: 'Password123!', password_confirmation: 'Password123!')

    jti = SecureRandom.uuid
    MagicLinkToken.register(jti)
    token = JwtAuth.encode({ user_id: @admin.id, jti: jti }, 15.minutes.from_now)
    get magic_link_path(token: token)

    assert_redirected_to two_factor_challenge_path
  end

  test 'magic link signs in a non-OTP-required user directly' do
    @user = create(:god, password: 'Password123!', password_confirmation: 'Password123!')
    User.where(id: @user.id).update_all(otp_required_for_login: false, type: 'Users::Employer')

    jti = SecureRandom.uuid
    MagicLinkToken.register(jti)
    token = JwtAuth.encode({ user_id: @user.id, jti: jti }, 15.minutes.from_now)
    get magic_link_path(token: token)

    follow_redirect!
    assert_match 'Connexion réussie', response.body
  end

  test 'magic link without jti is rejected' do
    @admin = create(:god, password: 'Password123!', password_confirmation: 'Password123!')

    token = JwtAuth.encode({ user_id: @admin.id }, 15.minutes.from_now)
    get magic_link_path(token: token)

    assert_redirected_to new_user_session_path
    assert_equal 'Lien invalide ou expiré.', flash[:alert]
  end

  test 'magic link cannot be replayed after first use' do
    @admin = create(:god, password: 'Password123!', password_confirmation: 'Password123!')

    jti = SecureRandom.uuid
    MagicLinkToken.register(jti)
    token = JwtAuth.encode({ user_id: @admin.id, jti: jti }, 15.minutes.from_now)

    get magic_link_path(token: token)
    assert_response :redirect
    assert_equal 0, $redis.exists(MagicLinkToken.send(:redis_key, jti)),
                 'JTI should have been consumed after first use'

    sign_out @admin
    get magic_link_path(token: token)
    assert_redirected_to new_user_session_path
    assert_equal 'Lien invalide ou expiré.', flash[:alert]
  end
end
