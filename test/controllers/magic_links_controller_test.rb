# frozen_string_literal: true

require 'test_helper'

class MagicLinksControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  test 'magic link signs in admin' do
    @admin = create(:god, password: 'Password123!', password_confirmation: 'Password123!')

    token = JwtAuth.encode({ user_id: @admin.id }, 15.minutes.from_now)
    get magic_link_path(token: token)

    follow_redirect!
    assert_match 'Connexion réussie', response.body
  end
end
