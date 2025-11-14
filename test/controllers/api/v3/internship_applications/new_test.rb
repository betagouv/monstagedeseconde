
require 'test_helper'

module Api
  module V3
    module InternshipApplications
      class NewTest < ActionDispatch::IntegrationTest
        include ::ApiTestHelpers

        setup do
          @student = create(:student_with_class_room_3e)
          post api_v3_auth_login_path(email: @student.email, password: @student.password)
          @token = json_response.dig('data', 'attributes', 'token')

          @employer = create(:employer)
          @internship_offer = create(:weekly_internship_offer_3eme, employer: @employer)
        end

        test 'GET #new without token renders :unauthorized payload' do
          get new_api_v3_internship_offer_internship_application_path(internship_offer_id: @internship_offer.id), params: {
            token: 'Bearer abcdefghijklmnop'
          }, as: :json
          assert_response :unauthorized
          assert_equal 'UNAUTHORIZED', json_code
        end

        test 'GET new application page with params' do
          get new_api_v3_internship_offer_internship_application_path(internship_offer_id: @internship_offer.id), params: {
            token: "Bearer #{@token}"
          }, as: :json
          assert_response :success
          attributes = json_response.dig('data', 'attributes')
          assert_equal @student.phone, attributes['student_phone']
          assert_equal @student.email, attributes['student_email']
          assert_equal @student.legal_representative_full_name, attributes['representative_full_name']
          assert_equal @student.legal_representative_email, attributes['representative_email']
          assert_equal @student.legal_representative_phone, attributes['representative_phone']
          assert attributes['weeks'].present?
          assert_equal '', attributes['motivation']
        end

        test 'GET new application page for 3e student with one week school, it should return the week' do
          @internship_offer.weeks = Week.both_school_tracks_weeks
          @internship_offer.save!
          week = Week.troisieme_selectable_weeks.last
          @student.school.weeks = [week]
          @student.school.save!

          get new_api_v3_internship_offer_internship_application_path(internship_offer_id: @internship_offer.id), params: {
            token: "Bearer #{@token}"
          }, as: :json

          assert_response :success
          attributes = json_response.dig('data', 'attributes')
          assert_equal @student.phone, attributes['student_phone']
          assert_equal @student.email, attributes['student_email']
          assert_equal @student.legal_representative_full_name, attributes['representative_full_name']
          assert_equal @student.legal_representative_email, attributes['representative_email']
          assert_equal @student.legal_representative_phone, attributes['representative_phone']
          assert_equal week.human_select_text_method, attributes['weeks'][0]['label']
          assert_equal false, attributes['weeks'][0]['selected']
          assert_equal '', attributes['motivation']
        end

        test 'GET new application page for 3e student with no school weeks, it should return all the offer s weeks' do
          @internship_offer.weeks = Week.troisieme_selectable_weeks.last(3)
          @internship_offer.save!
          @student.school.weeks = []
          @student.school.save!

          get new_api_v3_internship_offer_internship_application_path(internship_offer_id: @internship_offer.id), params: {
            token: "Bearer #{@token}"
          }, as: :json

          assert_response :success

          attributes = json_response.dig('data', 'attributes')
          assert_equal @student.phone, attributes['student_phone']
          assert_equal @student.email, attributes['student_email']
          assert_equal @student.legal_representative_full_name, attributes['representative_full_name']
          assert_equal @student.legal_representative_email, attributes['representative_email']
          assert_equal @student.legal_representative_phone, attributes['representative_phone']
          assert_equal @internship_offer.weeks.count, attributes['weeks'].count
          assert_equal '', attributes['motivation']
        end

        test 'GET new application page for 2nde student without other approved applications, it should return all seconde selectable weeks' do
          @student.update(grade: Grade.seconde)
          @internship_offer.weeks = SchoolTrack::Seconde.both_weeks
          @internship_offer.save!

          get new_api_v3_internship_offer_internship_application_path(internship_offer_id: @internship_offer.id), params: {
            token: "Bearer #{@token}"
          }, as: :json

          assert_response :success

          attributes = json_response.dig('data', 'attributes')
          assert_equal @student.phone, attributes['student_phone']
          assert_equal @student.email, attributes['student_email']
          assert_equal @student.legal_representative_full_name, attributes['representative_full_name']
          assert_equal @student.legal_representative_email, attributes['representative_email']
          assert_equal @student.legal_representative_phone, attributes['representative_phone']
          assert_equal @internship_offer.weeks.count, attributes['weeks'].count
          assert_equal '', attributes['motivation']
        end
      end
    end
  end
end
