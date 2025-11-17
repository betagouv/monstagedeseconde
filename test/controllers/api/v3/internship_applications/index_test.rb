require 'test_helper'

module Api
  module V3
    module InternshipApplications
      class IndexTest < ActionDispatch::IntegrationTest
        include ApiTestHelpers

        setup do
          @employer = create(:employer)
          post api_v3_auth_login_path(email: @employer.email, password: @employer.password)
          
          @employer_token = json_response.dig('id')

          @student = create(:student, :seconde)
          post api_v3_auth_login_path(email: @student.email, password: @student.password)
          @student_token = json_response.dig('id')

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
            assert_response :success
            assert_equal 1, json_response.count

            attributes = json_response.dig(0, 'attributes')
            assert_equal @internship_application.user_id, attributes['student_id']
            assert_equal @internship_application.uuid, attributes['uuid']
            assert_equal @internship_application.id, json_response.dig(0, 'id').to_i
            assert_equal @internship_application.internship_offer_id, attributes['internship_offer_id']
            assert_equal @internship_application.student_phone, attributes['student_phone']
            assert_equal @internship_application.student_email, attributes['student_email']
            assert_equal @internship_application.student_address, attributes['student_address']
            assert_equal @internship_application.aasm_state, attributes['state']
            assert_equal @internship_application.submitted_at.iso8601, attributes['submitted_at']
            assert_equal @internship_application.motivation, attributes['motivation']
            assert_equal @internship_application.student_legal_representative_email, attributes['student_legal_representative_email']
            assert_equal @internship_application.student_legal_representative_phone, attributes['student_legal_representative_phone']
            assert_equal @internship_application.student_legal_representative_full_name, attributes['student_legal_representative_full_name']
            assert_equal [{"id"=>181, "label"=>"Semaine du 15 juin au 19 juin", "selected"=>true}, {"id"=>182, "label"=>"Semaine du 22 juin au 26 juin", "selected"=>true}], attributes['weeks']
            end
          end
        end

        test 'GET #index as student renders all internship applications' do
          internship_offer_2 = create(:weekly_internship_offer_3eme, employer: @internship_application.internship_offer.employer)
          @internship_application_2 = create(:weekly_internship_application, student: @student, internship_offer: internship_offer_2)

          get api_v3_internship_applications_path, params: {
            token: "Bearer #{@student_token}",
          }, as: :json

          assert_response :success
        
          assert_equal 2, json_response.length
          attributes = json_response.dig(0, 'attributes')
          attributes_2 = json_response.dig(1, 'attributes')

          assert_equal @internship_application_2.id, json_response.dig(0, 'id').to_i
          assert_equal @internship_application_2.aasm_state, attributes_2['state']
          assert_equal @internship_application_2.internship_offer.employer_name, attributes_2['employer_name']
          assert_equal @internship_application_2.internship_offer.title, attributes['internship_offer_title']
          assert_equal @internship_application_2.presenter(@student).internship_offer_address, attributes_2['internship_offer_address']
          
          assert_equal @internship_application.id, json_response.dig(1, 'id').to_i
          assert_equal @internship_application.aasm_state, attributes['state']
          assert_equal @internship_application.internship_offer.employer_name, attributes['employer_name']
          assert_equal @internship_application.internship_offer.title, attributes_2['internship_offer_title']
          assert_equal @internship_application.presenter(@student).internship_offer_address, attributes['internship_offer_address']
          # assert_equal @internship_application.presenter(@student).str_weeks, json_response[0]['internship_offer_weeks']
          # assert_equal @internship_application_2.presenter(@student).str_weeks, json_response[1]['internship_offer_weeks']
        end

        test 'GET #index as employer when no application renders no applications for the internship offer' do
          InternshipApplication.destroy_all
          get api_v3_internship_applications_path, params: {
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
