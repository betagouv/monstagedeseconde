# frozen_string_literal: true

require 'test_helper'

module Api
  module V2
    module InternshipApplications
      class IndexTest < ActionDispatch::IntegrationTest
        include ::ApiTestHelpers

        setup do
          @student = create(:student_with_class_room_3e)
          post api_v2_auth_login_path(email: @student.email, password: @student.password)
          @token = json_response['token']
          @employer = create(:employer)
          @internship_offer = create(:weekly_internship_offer_3eme, employer: @employer)
        end

        test 'GET #index without token renders :unauthorized payload' do
          get api_v2_internship_offer_internship_applications_path(@internship_offer), params: {
            token: 'Bearer abcdefghijklmnop'
          }, as: :json
        end

        test 'GET #index renders all internship applications for the current student' do
          @internship_application_1 = create(:weekly_internship_application, student: @student, internship_offer: @internship_offer)
          internship_offer_2 = create(:weekly_internship_offer_3eme, employer: @employer)
          @internship_application_2 = create(:weekly_internship_application, student: @student, internship_offer: internship_offer_2)

          get api_v2_internship_offer_internship_applications_path(@internship_offer), params: {
            token: "Bearer #{@token}",
          }, as: :json

          assert_response :success
          assert_equal @internship_application_1.id, json_response['internship_applications'][0]['id']
          assert_equal @internship_application_2.id, json_response['internship_applications'][1]['id']
          assert_equal 2, json_response['internship_applications'].count
          assert_equal @internship_application_2.aasm_state, json_response['internship_applications'][1]['state']
          assert_equal @internship_application_2.internship_offer.employer_name, json_response['internship_applications'][1]['internship_offer_employer_name']
          assert_equal @internship_application_2.internship_offer.title, json_response['internship_applications'][1]['internship_offer_title']
          assert_equal @internship_application_2.presenter(@student).internship_offer_address, json_response['internship_applications'][1]['internship_offer_address']
          assert_equal @internship_application_2.presenter(@student).str_weeks, json_response['internship_applications'][1]['internship_offer_weeks']
        end

        test 'GET #index when no application renders no applications for the current student' do
          get api_v2_internship_offer_internship_applications_path(@internship_offer), params: {
            token: "Bearer #{@token}",
          }, as: :json

          assert_response :success
          assert_equal 0, json_response['internship_applications'].count
        end
      end
    end
  end
end