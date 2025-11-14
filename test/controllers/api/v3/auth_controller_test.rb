# frozen_string_literal: true

require 'test_helper'

module Api
  module V3
    class AuthControllerTest < ActionDispatch::IntegrationTest
      include ::ApiTestHelpers

      test 'login with valid credentials' do
        create(:user_operator, email: 'test@example.com', password: 'password123$-K')
        post api_v3_auth_login_path(email: 'test@example.com', password: 'password123$-K')
        assert_response :success
        assert_equal 'auth-token', json_response.dig('data', 'type')
        assert_not_nil json_response.dig('data', 'attributes', 'token')
      end

      test 'login with invalid credentials' do
        create(:user_operator, email: 'test@example.com', password: 'password123$-K')
        post api_v3_auth_login_path(email: 'test@example.com', password: 'wrong_password')
        assert_response :unauthorized
        assert_equal 'UNAUTHORIZED', json_code
      end
    end
  end
end
