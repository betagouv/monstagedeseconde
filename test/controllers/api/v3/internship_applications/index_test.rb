require 'test_helper'

module Api
  module V3
    module InternshipApplications
      class IndexTest < ActionDispatch::IntegrationTest
        include ApiTestHelpers

        setup do
          @employer = create(:employer)
          post api_v3_auth_login_path(email: @employer.email, password: @employer.password)
          @employer_token = json_response['token']

          @student = create(:student, :seconde)
          post api_v3_auth_login_path(email: @student.email, password: @student.password)
          @student_token = json_response['token']

          @internship_offer = create(:weekly_internship_offer, :both_weeks, employer: @employer, grades: [Grade.seconde])
          @internship_application = create(:weekly_internship_application, :both_june_weeks, internship_offer: @internship_offer, student: @student)
        end

        # before each test
        test 'GET #index as student without token renders :unauthorized payload' do
          get api_v3_internship_applications_path(params: {})
          documents_as(endpoint: :'v3/internship_applications/index', state: :unauthorized) do
            assert_response :unauthorized
            assert_equal 'UNAUTHORIZED', json_code
            assert_equal 'wrong api token', json_error
          end
        end

        test 'GET #index with wrong token renders :unauthorized payload' do
          get api_v3_internship_applications_path(params: {
              token: 'Bearer abcdefghijklmnop'
            })
          documents_as(endpoint: :'v3/internship_applications/index', state: :unauthorized) do
            assert_response :unauthorized
            assert_equal 'UNAUTHORIZED', json_code
            assert_equal 'wrong api token', json_error
          end
        end

        test "GET #index as student with token returns student's applications" do
          travel_to Time.zone.local(2025,3, 1) do
            create(:weekly_internship_application, :both_june_weeks, internship_offer: @internship_offer)
            create(:weekly_internship_application, :both_june_weeks)
            get api_v3_internship_applications_path(token: "Bearer #{@student_token}")
            documents_as(endpoint: :'v3/internship_applications/index', state: :ok) do
              assert_response :ok
              assert_response :success
              assert_equal 1, json_response.count
            
              assert_equal @internship_application.user_id, json_response[0]['student_id']
              assert_equal @internship_application.uuid, json_response[0]['uuid']
              assert_equal @internship_application.id, json_response[0]['id']
              assert_equal @internship_application.internship_offer_id, json_response[0]['internship_offer_id']
              assert_equal @internship_application.student_phone, json_response[0]['student_phone']
              assert_equal @internship_application.student_email, json_response[0]['student_email']
              assert_equal @internship_application.student_address, json_response[0]['student_address']
              assert_equal @internship_application.aasm_state, json_response[0]['state']
              assert_equal @internship_application.submitted_at.utc.iso8601, json_response[0]['submitted_at']
              assert_equal @internship_application.motivation, json_response[0]['motivation']
              assert_equal @internship_application.student_legal_representative_email, json_response[0]['student_legal_representative_email']
              assert_equal @internship_application.student_legal_representative_phone, json_response[0]['student_legal_representative_phone']
              assert_equal @internship_application.student_legal_representative_full_name, json_response[0]['student_legal_representative_full_name']
              assert_equal ["2026-W25", "2026-W26"], json_response[0]['weeks']
            end
          end
        end

       

        test 'GET #index renders all internship applications for one internship offer' do
          internship_offer_2 = create(:weekly_internship_offer_3eme, employer: @internship_application.internship_offer.employer)
          @internship_application_2 = create(:weekly_internship_application, student: @student, internship_offer: internship_offer_2)

          get api_v3_internship_offer_internship_applications_path(@internship_offer), params: {
            token: "Bearer #{@token}",
          }, as: :json

          assert_response :success
          assert_equal 1, json_response.length
          assert_equal @internship_application.id, json_response[0]['id']
          assert_equal @internship_application.aasm_state, json_response[0]['state']
          assert_equal @internship_application.internship_offer.employer_name, json_response[0]['employer_name']
          assert_equal @internship_application.internship_offer.title, json_response[0]['internship_offer_title']
          assert_equal @internship_application.presenter(@student).internship_offer_address, json_response[0]['internship_offer_address']
          # assert_equal @internship_application.presenter(@student).str_weeks, json_response[0]['internship_offer_weeks']
        end

        test 'GET #index as employer when no application renders no applications for the internship offer' do
          InternshipApplication.destroy_all
          get api_v3_internship_offer_internship_applications_path(@internship_offer), params: {
            token: "Bearer #{@employer_token}",
          }, as: :json

          assert_response :success
          assert_equal 0, json_response.length
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
