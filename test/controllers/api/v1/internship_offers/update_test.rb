# frozen_string_literal: true

require 'test_helper'

module Api
  module V1
    class InternshipOffersUpdateTest < ActionDispatch::IntegrationTest
      include ApiTestHelpers

      setup do
        travel_to Date.new(2023, 10, 1) do
          @operator = create(:user_operator)
          @internship_offer = create(:api_internship_offer_3eme, employer: @operator)
        end
      end

      test 'PATCH #update without token renders :unauthorized payload' do
        documents_as(endpoint: :'internship_offers/update', state: :unauthorized) do
          patch api_v1_internship_offer_path(id: @internship_offer.remote_id)
        end
        assert_response :unauthorized
        assert_equal 'UNAUTHORIZED', json_response['code']
        assert_equal 'wrong api token', json_error
      end

      test 'PATCH #update as operator fails with invalid payload respond with :unprocessable_entity' do
        documents_as(endpoint: :'internship_offers/update', state: :unprocessable_entity_bad_payload) do
          patch api_v1_internship_offer_path(
            id: @internship_offer.remote_id,
            params: {
              token: "Bearer #{@operator.api_token}"
            }
          )
        end
        assert_response :unprocessable_entity
        assert_equal 'BAD_PAYLOAD', json_response['code']
        assert_equal 'param is missing or the value is empty: internship_offer', json_error
      end

      test 'PATCH #update an internship_offer which does not belongs to current auth operator' do
        bad_operator = create(:user_operator)
        documents_as(endpoint: :'internship_offers/update', state: :forbidden) do
          patch api_v1_internship_offer_path(
            id: @internship_offer.remote_id,
            params: {
              token: "Bearer #{bad_operator.api_token}",
              internship_offer: {
                title: ''
              }
            }
          )
        end
        assert_response :forbidden
        assert_equal 'FORBIDDEN', json_response['code']
        assert_equal 'You are not authorized to access this page.', json_error
      end

      test 'PATCH #update as operator fails with invalid remote_id' do
        documents_as(endpoint: :'internship_offers/update', state: :not_found) do
          patch api_v1_internship_offer_path(
            id: 'foo',
            params: {
              token: "Bearer #{@operator.api_token}",
              internship_offer: {
                description: 'a' * (InternshipOffer::DESCRIPTION_MAX_CHAR_COUNT + 2)
              }
            }
          )
        end
        assert_response :not_found
        assert_equal 'NOT_FOUND', json_response['code']
        assert_equal "can't find internship_offer with this remote_id", json_error
      end

      test 'PATCH #update as operator fails with invalid data respond with :bad_request' do
        documents_as(endpoint: :'internship_offers/update', state: :bad_request) do
          patch api_v1_internship_offer_path(
            id: @internship_offer.remote_id,
            params: {
              token: "Bearer #{@operator.api_token}",
              internship_offer: {
                description: 'a' * (InternshipOffer::DESCRIPTION_MAX_CHAR_COUNT + 2)
              }
            }
          )
        end
        assert_response :bad_request
        assert_equal 'VALIDATION_ERROR', json_response['code']
        assert_equal ['Description too long, allowed up 500 chars'],
                     json_error['description'],
                     'bad description error '
      end

      test 'PATCH #update as operator fails with invalid period respond with :bad_request' do
        documents_as(endpoint: :'internship_offers/update', state: :bad_request) do
          patch api_v1_internship_offer_path(
            id: @internship_offer.remote_id,
            params: {
              token: "Bearer #{@operator.api_token}",
              internship_offer: {
                period: 12
              }
            }
          )
        end
        assert_response :bad_request
        assert_equal 401, json_response['code']
        assert_equal ["n'est pas inclus(e) dans la liste"], json_error['period']
      end

      test 'PATCH #update as operator works to internship_offers' do
        new_title = 'hellow'

        documents_as(endpoint: :'internship_offers/update', state: :ok) do
          patch api_v1_internship_offer_path(
            id: @internship_offer.remote_id,
            params: {
              token: "Bearer #{@operator.api_token}",
              internship_offer: {
                title: new_title,
                max_candidates: 2,
                published_at: nil,
                is_public: true,
                handicap_accessible: true,
                period: 2
              }
            }
          )
        end
        assert_response :success
        assert_equal new_title, @internship_offer.reload.title
        assert_equal 2, @internship_offer.max_candidates
        assert_equal JSON.parse(@internship_offer.to_json), json_response
        assert @internship_offer.reload.is_public
        assert @internship_offer.reload.handicap_accessible
        assert_equal 2, @internship_offer.period
        assert_equal 1, @internship_offer.weeks.count
      end

      test 'PATCH #update as operator unpublish/republish internship_offers' do
        patch api_v1_internship_offer_path(
          id: @internship_offer.remote_id,
          params: {
            token: "Bearer #{@operator.api_token}",
            internship_offer: {
              published_at: nil
            }
          }
        )
        assert_response :success
        assert_nil @internship_offer.reload.published_at
        refute @internship_offer.published?

        new_publication_date = Time.now.utc
        patch api_v1_internship_offer_path(
          id: @internship_offer.remote_id,
          params: {
            token: "Bearer #{@operator.api_token}",
            internship_offer: {
              published_at: new_publication_date
            }
          }
        )
        assert_response :success
        assert_in_delta Time.now.to_i, @internship_offer.reload.published_at.to_i, 2
        assert_equal true, @internship_offer.published?
      end
    end
  end
end
