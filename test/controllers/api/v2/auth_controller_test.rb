# frozen_string_literal: true

require 'test_helper'

module Api
  module V2
    class AuthControllerTest < ActionDispatch::IntegrationTest
      include ::ApiTestHelpers

      test 'login with valid credentials' do
        create(:user_operator, email: 'test@example.com', password: 'password123$-K')
        post api_v2_auth_login_path(email: 'test@example.com', password: 'password123$-K')
        assert_response :success
        assert_not_nil json_response['token']
      end

      test 'login with invalid credentials' do
        create(:user_operator, email: 'test@example.com', password: 'password123$-K')
        post api_v2_auth_login_path(email: 'test@example.com', password: 'wrong_password')
        assert_response :unauthorized
      end
    end
  end
end
