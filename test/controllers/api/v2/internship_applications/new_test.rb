
require 'test_helper'

module Api
  module V2
    module InternshipApplications
      class NewTest < ActionDispatch::IntegrationTest
        include ::ApiTestHelpers

        setup do
          @student = create(:student_with_class_room_3e)
          post api_v2_auth_login_path(email: @student.email, password: @student.password)
          @token = json_response['token']

          @employer = create(:employer)
          @internship_offer = create(:weekly_internship_offer_3eme, employer: @employer)
        end

        test 'GET #new without token renders :unauthorized payload' do
          get new_api_v2_internship_offer_internship_application_path(internship_offer_id: @internship_offer.id), params: {
            token: 'Bearer abcdefghijklmnop'
          }, as: :json
        end

        test 'GET new application page with params' do
          get new_api_v2_internship_offer_internship_application_path(internship_offer_id: @internship_offer.id), params: {
            token: "Bearer #{@token}"
          }, as: :json
          assert_response :success
          assert_equal @student.phone, json_response['student_phone']
          assert_equal @student.email, json_response['student_email']
          assert_equal @student.legal_representative_full_name, json_response['representative_full_name']
          assert_equal @student.legal_representative_email, json_response['representative_email']
          assert_equal @student.legal_representative_phone, json_response['representative_phone']
          assert json_response['weeks'].present?
          assert_equal '', json_response['motivation']
        end

        test 'GET new application page for 3e student with one week school, it should return the week' do
          @internship_offer.weeks = Week.both_school_tracks_weeks
          @internship_offer.save!
          week = Week.troisieme_selectable_weeks.last
          @student.school.weeks = [week]
          @student.school.save!

          get new_api_v2_internship_offer_internship_application_path(internship_offer_id: @internship_offer.id), params: {
            token: "Bearer #{@token}"
          }, as: :json

          assert_response :success

          assert_equal @student.phone, json_response['student_phone']
          assert_equal @student.email, json_response['student_email']
          assert_equal @student.legal_representative_full_name, json_response['representative_full_name']
          assert_equal @student.legal_representative_email, json_response['representative_email']
          assert_equal @student.legal_representative_phone, json_response['representative_phone']
          assert_equal week.id, json_response['weeks'][0]['id']
          assert_equal week.human_select_text_method, json_response['weeks'][0]['label']
          assert_equal false, json_response['weeks'][0]['selected']
          assert_equal '', json_response['motivation']
        end

        test 'GET new application page for 3e student with no school weeks, it should return all the offer s weeks' do
          @internship_offer.weeks = Week.troisieme_selectable_weeks.last(3)
          @internship_offer.save!
          @student.school.weeks = []
          @student.school.save!

          get new_api_v2_internship_offer_internship_application_path(internship_offer_id: @internship_offer.id), params: {
            token: "Bearer #{@token}"
          }, as: :json

          assert_response :success

          assert_equal @student.phone, json_response['student_phone']
          assert_equal @student.email, json_response['student_email']
          assert_equal @student.legal_representative_full_name, json_response['representative_full_name']
          assert_equal @student.legal_representative_email, json_response['representative_email']
          assert_equal @student.legal_representative_phone, json_response['representative_phone']
          assert_equal @internship_offer.weeks.count, json_response['weeks'].count
          assert_equal '', json_response['motivation']
        end

        test 'GET new application page for 2nde student without other approved applications, it should return all seconde selectable weeks' do
          @student.update(grade: Grade.seconde)
          @internship_offer.weeks = SchoolTrack::Seconde.both_weeks
          @internship_offer.save!

          get new_api_v2_internship_offer_internship_application_path(internship_offer_id: @internship_offer.id), params: {
            token: "Bearer #{@token}"
          }, as: :json

          assert_response :success

          assert_equal @student.phone, json_response['student_phone']
          assert_equal @student.email, json_response['student_email']
          assert_equal @student.legal_representative_full_name, json_response['representative_full_name']
          assert_equal @student.legal_representative_email, json_response['representative_email']
          assert_equal @student.legal_representative_phone, json_response['representative_phone']
          assert_equal @internship_offer.weeks.count, json_response['weeks'].count
          assert_equal '', json_response['motivation']
        end
      end
    end
  end
end
