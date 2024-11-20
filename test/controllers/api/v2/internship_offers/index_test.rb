# frozen_string_literal: true

require 'test_helper'

module Api
  module V2
    class IndexTest < ActionDispatch::IntegrationTest
      include ::ApiTestHelpers

      setup do
        @operator = create(:user_operator)
        post api_v2_auth_login_path(email: @operator.email, password: @operator.password)
        @token = json_response['token']
      end

      test 'GET #index without token renders :unauthorized payload' do
        get api_v2_internship_offers_path(params: {})
        documents_as(endpoint: :'v2/internship_offers/index', state: :unauthorized) do
          assert_response :unauthorized
          assert_equal 'UNAUTHORIZED', json_code
          assert_equal 'wrong api token', json_error
        end
      end

      test 'GET #index renders :unauthorized payload' do
        operator = @operator.operator.update(api_full_access: false)

        documents_as(endpoint: :'v2/internship_offers/index', state: :unauthorized) do
          get api_v2_internship_offers_path(
            params: {
              token: 'Bearer abcdefghijklmnop'
            }
          )

          assert_response :unauthorized
          assert_equal 'UNAUTHORIZED', json_code
          assert_equal 'wrong api token', json_error
        end
      end

      test 'GET #index only returns operators offers' do
        user_1 = @operator
        user_2 = create(:user_operator)

        offer_1     = create(:api_internship_offer_3eme, employer: user_1)
        offer_1_bis = create(:api_internship_offer_3eme, employer: user_1)
        offer_2     = create(:api_internship_offer_3eme, employer: user_2)

        documents_as(endpoint: :'v2/internship_offers/index', state: :success) do
          get api_v2_internship_offers_path(
            params: {
              token: "Bearer #{@token}",
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

      test 'GET #index only returns operators offers not discarded' do
        offer_1 = create(:api_internship_offer_3eme, employer: @operator)
        offer_2 = create(:api_internship_offer_3eme, employer: @operator)

        # Delete the first offer
        delete api_v2_internship_offer_path(
          id: offer_1.remote_id,
          params: {
            token: "Bearer #{@token}"
          }
        )

        offer_1.reload
        assert offer_1.discarded?

        # Get only the second offer
        documents_as(endpoint: :'v2/internship_offers/index', state: :success) do
          get api_v2_internship_offers_path(
            params: {
              token: "Bearer #{@token}",
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
