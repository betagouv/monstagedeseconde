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
        token = json_response['token']

        get api_v3_me_path(token: "Bearer #{token}")

        assert_response :success
        assert_equal @student.id.to_s, json_response['id']
        assert_equal @student.email, json_response['attributes']['email']
        assert_equal @student.first_name, json_response['attributes']['first_name']
        assert_equal @student.last_name, json_response['attributes']['last_name']
      end

      test 'GET #show as employer returns current user data' do
        @employer = create(:employer)
        post api_v3_auth_login_path(email: @employer.email, password: @employer.password)
        token = json_response['token']

        get api_v3_me_path(token: "Bearer #{token}")

        assert_response :success
        assert_equal @employer.id.to_s, json_response['id']
        assert_equal @employer.email, json_response['attributes']['email']
        assert_equal @employer.first_name, json_response['attributes']['first_name']
        assert_equal @employer.last_name, json_response['attributes']['last_name']
      end

      test 'GET #show as operator returns current user data' do
        @operator = create(:user_operator)
        post api_v3_auth_login_path(email: @operator.email, password: @operator.password)
        token = json_response['token']

        get api_v3_me_path(token: "Bearer #{token}")

        assert_response :success
        assert_equal @operator.id.to_s, json_response['id']
        assert_equal @operator.email, json_response['attributes']['email']
        assert_equal @operator.first_name, json_response['attributes']['first_name']
        assert_equal @operator.last_name, json_response['attributes']['last_name']
      end
    end
  end
end

