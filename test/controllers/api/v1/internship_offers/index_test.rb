# frozen_string_literal: true

require 'test_helper'

module Api
  module V1
    class IndexTest < ActionDispatch::IntegrationTest
      include ::ApiTestHelpers

      test 'GET #index without token renders :unauthorized payload' do
        get api_v1_internship_offers_path(params: {})
        documents_as(endpoint: :'internship_offers/index', state: :unauthorized) do
          assert_response :unauthorized
          assert_equal 'UNAUTHORIZED', json_code
          assert_equal 'wrong api token', json_error
        end
      end

      test 'GET #index renders :unauthorized payload' do
        user = create(:user_operator)
        operator = user.operator.update(api_full_access: false)

        documents_as(endpoint: :'internship_offers/index', state: :unauthorized) do
          get api_v1_internship_offers_path(
            params: {
              token: 'Bearer abcdefghijklmnop'
            }
          )

          assert_response :unauthorized
          assert_equal 'UNAUTHORIZED', json_code
          assert_equal 'wrong api token', json_error
        end
      end

      # TO DO : fix this redirect
      # test 'GET #index without api version works' do
      #   user_1 = create(:user_operator)
      #   offer_1 = create(:api_internship_offer_3eme, employer: user_1)

      #   get '/api/internship_offers', params: {
      #     token: "Bearer #{user_1.api_token}",
      #     page: 1
      #   }

      #   assert_redirected_to api_v1_internship_offers_path
      # end

      test 'GET #index only returns operators offers' do
        travel_to Date.new(2023, 10, 1) do
          user_1 = create(:user_operator)
          user_2 = create(:user_operator)

          offer_1     = create(:api_internship_offer_3eme, employer: user_1)
          offer_1_bis = create(:api_internship_offer_3eme, employer: user_1)
          offer_2     = create(:api_internship_offer_3eme, employer: user_2)

          documents_as(endpoint: :'internship_offers/index', state: :success) do
            get api_v1_internship_offers_path(
              params: {
                token: "Bearer #{user_1.api_token}",
                page: 1
              }
            )

            assert_response :success
            assert_equal 2, json_response['internshipOffers'].count
            assert_equal 2, json_response['pagination']['totalInternshipOffers']
            assert_equal 1, json_response['pagination']['totalPages']
            assert_equal true, json_response['pagination']['isFirstPage']
          end
        end
      end

      test 'GET #index only returns operators offers not discarded' do
        travel_to Date.new(2023, 10, 1) do
          user = create(:user_operator)

          offer_1 = create(:api_internship_offer_3eme, employer: user)
          offer_2 = create(:api_internship_offer_3eme, employer: user)

          # Delete the first offer
          delete api_v1_internship_offer_path(
            id: offer_1.remote_id,
            params: {
              token: "Bearer #{user.api_token}"
            }
          )

          offer_1.reload
          assert offer_1.discarded?

          # Get only the second offer
          documents_as(endpoint: :'internship_offers/index', state: :success) do
            get api_v1_internship_offers_path(
              params: {
                token: "Bearer #{user.api_token}",
                page: 1
              }
            )

            assert_response :success
            assert_equal 1, json_response['internshipOffers'].count
            assert_equal 1, json_response['pagination']['totalInternshipOffers']
            assert_equal 1, json_response['pagination']['totalPages']
            assert_equal true, json_response['pagination']['isFirstPage']
          end
        end
      end
    end
  end
end
