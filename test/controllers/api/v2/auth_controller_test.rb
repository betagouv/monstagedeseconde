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

      test 'login is restricted to operators (employer-only email is rejected)' do
        create(:employer, email: 'shared@example.com', password: 'password123$-K')
        post api_v2_auth_login_path(email: 'shared@example.com', password: 'password123$-K')
        assert_response :unauthorized
      end

      test 'login resolves to the operator account when a non-operator shares the email' do
        operator = create(:user_operator, email: 'shared@example.com', password: 'shared123$-K')
        employer = build(:employer, email: 'shared@example.com', password: 'shared123$-K')
        employer.save(validate: false)

        post api_v2_auth_login_path(email: 'shared@example.com', password: 'shared123$-K')

        assert_response :success
        decoded = JwtAuth.decode(json_response['token'])
        assert_equal operator.id, decoded[:user_id]
      end
    end
  end
end
