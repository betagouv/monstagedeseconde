# frozen_string_literal: true

require 'test_helper'

module Api
  module V3
    class MeControllerTest < ActionDispatch::IntegrationTest
      include ::ApiTestHelpers

      setup do
        @student = create(:student_with_class_room_3e)
      end

      test 'GET #show without token renders :unauthorized payload' do
        get api_v3_me_path

        assert_response :unauthorized
        assert_equal 'UNAUTHORIZED', json_code
        assert_equal 'wrong api token', json_error
      end

      test 'GET #show as student returns current user data' do
        post api_v3_auth_login_path(email: @student.email, password: @student.password)
        token = json_attributes['token']

        get api_v3_me_path(token: "Bearer #{token}")

        assert_response :success
        assert_equal 'user', json_data['type']
        assert_equal @student.id.to_s, json_id
        assert_equal @student.email, json_attributes['email']
        assert_equal 'student', json_attributes['role']
      end

      test 'GET #show as employer returns current user data' do
        @employer = create(:employer)
        post api_v3_auth_login_path(email: @employer.email, password: @employer.password)
        token = json_attributes['token']

        get api_v3_me_path(token: "Bearer #{token}")

        assert_response :success
        assert_equal 'user', json_data['type']
      end

      test 'GET #show as operator returns current user data' do
        @operator = create(:user_operator)
        post api_v3_auth_login_path(email: @operator.email, password: @operator.password)
        token = json_attributes['token']

        get api_v3_me_path(token: "Bearer #{token}")

        assert_response :success
        assert_equal 'user', json_data['type']
      end
    end
  end
end

