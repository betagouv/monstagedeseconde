require 'test_helper'

module Api
  module V2
    module InternshipApplications
      class IndexTest < ActionDispatch::IntegrationTest
        include ApiTestHelpers

        setup do
          @operator = create(:user_operator, api_token: SecureRandom.uuid)
          post api_v2_auth_login_path(email: @operator.email, password: @operator.password)
          @token = json_response['token']

          @student = create(:student, :seconde)
          @internship_offer = create(:weekly_internship_offer, :both_weeks, employer: @operator, grades: [Grade.seconde])
          @internship_application = create(:weekly_internship_application, :both_june_weeks, internship_offer: @internship_offer, student: @student)
        end

        # before each test
        test 'GET #index without token renders :unauthorized payload' do
          get api_v2_students_internship_applications_path(student_id: @student.id)
          documents_as(endpoint: :'v2/internship_applications/index', state: :unauthorized) do
            assert_response :unauthorized
            assert_equal 'UNAUTHORIZED', json_code
            assert_equal 'wrong api token', json_error
          end
        end

        test 'GET #index with wrong token renders :unauthorized payload' do
          get api_v2_students_internship_applications_path(student_id: @student.id, params: {
              token: 'Bearer abcdefghijklmnop'
            })
          documents_as(endpoint: :'v2/internship_applications/index', state: :unauthorized) do
            assert_response :unauthorized
            assert_equal 'UNAUTHORIZED', json_code
            assert_equal 'wrong api token', json_error
          end
        end

        test "GET #index with token returns student's applications" do
          travel_to Time.zone.local(2025,3, 1) do
            create(:weekly_internship_application, :both_june_weeks, internship_offer: @internship_offer)
            create(:weekly_internship_application, :both_june_weeks)
            get api_v2_students_internship_applications_path(student_id: @student.id, token: "Bearer #{@token}")
            documents_as(endpoint: :'v2/internship_applications/index', state: :ok) do
              assert_response :ok
              assert_response :success
              assert_equal 1, json_response['internshipApplications'].count
              assert_equal @internship_application.user_id, json_response['internshipApplications'][0]['user_id']
              assert_equal @internship_application.id, json_response['internshipApplications'][0]['id']
              assert_equal @internship_application.internship_offer_id, json_response['internshipApplications'][0]['internship_offer_id']
              assert_equal @internship_application.student_phone, json_response['internshipApplications'][0]['student_phone']
              assert_equal @internship_application.student_email, json_response['internshipApplications'][0]['student_email']
              assert_equal @internship_application.student_legal_representative_email, json_response['internshipApplications'][0]['student_legal_representative_email']
              assert_equal @internship_application.student_legal_representative_phone, json_response['internshipApplications'][0]['student_legal_representative_phone']
              assert_equal @internship_application.student_legal_representative_full_name, json_response['internshipApplications'][0]['student_legal_representative_full_name']
              assert_equal ["2026-W25", "2026-W26"], json_response['internshipApplications'][0]['weeks']
            end
          end
        end

        test 'PATCH #update as operator fails with invalid payload respond with :unprocessable_entity_bad_payload' do
          travel_to Time.zone.local(2025, 5, 11) do
            documents_as(endpoint: :'v2/internship_applications/index', state: :unprocessable_entity_bad_payload) do
              get api_v2_students_internship_applications_path(
                student_id: 'test',
                params: {
                  token: "Bearer #{@token}"
                }
              )
            end
            assert_response :unprocessable_entity
            assert_equal 'BAD_PAYLOAD', json_response['code']
            assert_equal 'missing or invalid student_id', json_error
          end
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

#         setup do
#           @student = create(:student_with_class_room_3e)
#           post api_v2_auth_login_path(email: @student.email, password: @student.password)
#           @token = json_response['token']
#           @employer = create(:employer)
#           @internship_offer = create(:weekly_internship_offer_3eme, employer: @employer)
#         end

        
#       end
#     end
#   end
# end
