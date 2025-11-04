# frozen_string_literal: true

require 'test_helper'

module Api
  module V2
    module InternshipApplications
      class CreateTest < ActionDispatch::IntegrationTest
        include ::ApiTestHelpers

        setup do
          @student = create(:student_with_class_room_3e)
          post api_v2_auth_login_path(email: @student.email, password: @student.password)
          @token = json_response['token']
          
          @employer = create(:employer)
          @sector = create(:sector)
          @school = create(:school, :with_school_manager, zipcode: '75001')
          @student.update(school: @school, class_room: create(:class_room, school: @school))
          
          @week_1 = Week.find_by(year: 2025, number: 20)
          @week_2 = Week.find_by(year: 2025, number: 21)
          @week_3 = Week.find_by(year: 2025, number: 22)
          
          @internship_offer = create(
            :weekly_internship_offer_3eme,
            employer: @employer,
            sector: @sector,
            weeks: [@week_1, @week_2, @week_3]
          )
        end

        test 'POST #create without token renders :unauthorized payload' do
          post api_v2_internship_offer_internship_applications_path(@internship_offer), params: {
            token: 'Bearer abcdefghijklmnop'
          }, as: :json do
            assert_response :unauthorized
            assert_equal 'UNAUTHORIZED', json_code
          end
        end

        test 'POST #create as student with valid params creates internship application' do
          application_params = {
            user_id: @student.id,
            internship_application: {
              student_phone: '0611223344',
              student_email: 'student@example.com',
              week_ids: [@week_1.id, @week_2.id],
              motivation: 'Je suis très motivé pour ce stage',
              student_address: '123 rue de la République, 75001 Paris',
              student_legal_representative_full_name: 'Jean Dupont',
              student_legal_representative_email: 'parent@example.com',
              student_legal_representative_phone: '0612345678'
            }
          }

          assert_difference 'InternshipApplication.count', 1 do
            documents_as(endpoint: :'v2/internship_applications/create', state: :created) do
              post api_v2_internship_offer_internship_applications_path(@internship_offer),
                   params: application_params.merge(token: "Bearer #{@token}"),
                   as: :json
            end
          end

          assert_response :created
          response_data = json_response
          
          assert_equal @internship_offer.id, response_data['internship_offer_id']
          assert_equal @student.id, response_data['student_id']
          assert_equal 'submitted', response_data['aasm_state']
          assert_equal 'Je suis très motivé pour ce stage', response_data['motivation']
          assert_equal '+33611223344', response_data['student_phone']
          assert_equal 'student@example.com', response_data['student_email']
          assert_equal '123 rue de la République, 75001 Paris', response_data['student_address']
          assert_equal 'Jean Dupont', response_data['student_legal_representative_full_name']
          assert_equal 'parent@example.com', response_data['student_legal_representative_email']
          assert_equal '+33612345678', response_data['student_legal_representative_phone']
          assert_equal 2, response_data['weeks'].size
          assert_includes response_data['weeks'], '2025-W20'
          assert_includes response_data['weeks'], '2025-W21'
          assert response_data['uuid'].present?
          assert response_data['submitted_at'].present?
        end

        test 'POST #create as operator (not student) renders :forbidden' do
          operator = create(:user_operator, email: 'operator@example.com', password: 'Password123!')
          post api_v2_auth_login_path(email: operator.email, password: operator.password)
          operator_token = json_response['token']
          student = create(:student)

          application_params = {
            internship_application: {
              user_id: student.id,
              student_phone: '0611223344',
              student_email: student.email,
              week_ids: [@week_1.id],
              motivation: 'Je suis très motivé pour ce stage',
              student_address: '123 rue de la République, 75001 Paris',
              student_legal_representative_full_name: 'Jean Dupont',
              student_legal_representative_email: 'parent@example.com',
              student_legal_representative_phone: '0612345678'
            }
          }

          documents_as(endpoint: :'v2/internship_applications/create', state: :forbidden) do
            post api_v2_internship_offer_internship_applications_path(@internship_offer),
                 params: application_params.merge(token: "Bearer #{operator_token}"),
                 as: :json
          end

          assert_response :unprocessable_entity
          assert_equal 'VALIDATION_ERROR', json_response['error']
          assert_equal 'The internship application could not be created', json_response['message']
        end

        test 'POST #create with missing internship_offer_id renders :not_found' do
          application_params = {
            user_id: @student.id,
            internship_application: {
              student_phone: '0611223344',
              student_email: 'student@example.com',
              week_ids: [@week_1.id],
              motivation: 'Je suis très motivé',
              student_address: '123 rue de la République, 75001 Paris',
              student_legal_representative_full_name: 'Jean Dupont',
              student_legal_representative_email: 'parent@example.com',
              student_legal_representative_phone: '0612345678'
            }
          }

          documents_as(endpoint: :'v2/internship_applications/create', state: :not_found) do
            post api_v2_internship_offer_internship_applications_path(999_999),
                 params: application_params.merge(token: "Bearer #{@token}"),
                 as: :json
          end

          assert_response :not_found
          assert_equal 'NOT_FOUND', json_response['error']
          assert_equal 'Internship offer not found', json_response['message']
        end

        test 'POST #create without required params renders :bad_request' do
          application_params = {
            user_id: @student.id,
            internship_application: {
              motivation: 'Je suis très motivé',
            }
          }

          documents_as(endpoint: :'v2/internship_applications/create', state: :bad_request) do
            post api_v2_internship_offer_internship_applications_path(@internship_offer),
                 params: application_params.merge(token: "Bearer #{@token}"),
                 as: :json
          end

          assert_response :bad_request
          assert_equal 'MISSING_PARAMETER', json_response['error']
          assert json_response['message'].include?('Missing required parameter')
        end

        test 'POST #create with invalid email renders :unprocessable_entity' do
          application_params = {
            user_id: @student.id,
            internship_application: {
              student_phone: '0611223344',
              student_email: 'invalid-email',
              week_ids: [@week_1.id],
              motivation: 'Je suis très motivé',
              student_address: '123 rue de la République, 75001 Paris',
              student_legal_representative_full_name: 'Jean Dupont',
              student_legal_representative_email: 'parent@example.com',
              student_legal_representative_phone: '0612345678'
            }
          }

          documents_as(endpoint: :'v2/internship_applications/create', state: :unprocessable_entity) do
            post api_v2_internship_offer_internship_applications_path(@internship_offer),
                 params: application_params.merge(token: "Bearer #{@token}"),
                 as: :json
          end

          assert_response :unprocessable_entity
          assert_equal 'VALIDATION_ERROR', json_response['error']
          assert_equal 'The internship application could not be created', json_response['message']
          assert json_response['details'].present?
        end

        test 'POST #create with invalid phone number renders :unprocessable_entity' do
          application_params = {
            user_id: @student.id,
            internship_application: {
              student_phone: '123',
              student_email: 'student@example.com',
              week_ids: [@week_1.id],
              motivation: 'Je suis très motivé',
              student_address: '123 rue de la République, 75001 Paris',
              student_legal_representative_full_name: 'Jean Dupont',
              student_legal_representative_email: 'parent@example.com',
              student_legal_representative_phone: '0612345678'
            }
          }

          post api_v2_internship_offer_internship_applications_path(@internship_offer),
               params: application_params.merge(token: "Bearer #{@token}"),
               as: :json

          assert_response :unprocessable_entity
          assert_equal 'VALIDATION_ERROR', json_response['error']
          assert json_response['details'].any? { |msg| msg.include?('téléphone') }
        end

        test 'POST #create with empty week_ids renders :unprocessable_entity' do
          application_params = {
            user_id: @student.id,
            internship_application: {
              student_phone: '0611223344',
              student_email: 'student@example.com',
              week_ids: [],
              motivation: 'Je suis très motivé',
              student_address: '123 rue de la République, 75001 Paris',
              student_legal_representative_full_name: 'Jean Dupont',
              student_legal_representative_email: 'parent@example.com',
              student_legal_representative_phone: '0612345678'
            }
          }

          post api_v2_internship_offer_internship_applications_path(@internship_offer),
               params: application_params.merge(token: "Bearer #{@token}"),
               as: :json

          assert_response :bad_request
          assert_equal 'MISSING_PARAMETER', json_response['error']
          assert json_response['message'].include?('Missing required parameter')
        end

        test 'POST #create formats week_ids correctly when passed as string' do
          application_params = {
            user_id: @student.id,
            internship_application: {
              student_phone: '0611223344',
              student_email: 'student@example.com',
              week_ids: [@week_1.id, @week_2.id],
              motivation: 'Je suis très motivé',
              student_address: '123 rue de la République, 75001 Paris',
              student_legal_representative_full_name: 'Jean Dupont',
              student_legal_representative_email: 'parent@example.com',
              student_legal_representative_phone: '0612345678'
            }
          }

          assert_difference 'InternshipApplication.count', 1 do
            post api_v2_internship_offer_internship_applications_path(@internship_offer),
                 params: application_params.merge(token: "Bearer #{@token}"),
                 as: :json
          end

          assert_response :created
          created_application = InternshipApplication.last
          assert_equal 2, created_application.weeks.count
        end

        test 'POST #create sanitizes phone number by removing spaces' do
          application_params = {
            user_id: @student.id,
            internship_application: {
              student_phone: '06 11 22 33 44',
              student_email: 'student@example.com',
              week_ids: [@week_1.id],
              motivation: 'Je suis très motivé',
              student_address: '123 rue de la République, 75001 Paris',
              student_legal_representative_full_name: 'Jean Dupont',
              student_legal_representative_email: 'parent@example.com',
              student_legal_representative_phone: '0612345678'
            }
          }

          assert_difference 'InternshipApplication.count', 1 do
            post api_v2_internship_offer_internship_applications_path(@internship_offer),
                 params: application_params.merge(token: "Bearer #{@token}"),
                 as: :json
          end

          assert_response :created
          created_application = InternshipApplication.last
          assert_equal '+33611223344', created_application.student_phone
        end
      end
    end
  end
end


