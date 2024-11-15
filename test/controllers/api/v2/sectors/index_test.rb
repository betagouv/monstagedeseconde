require 'test_helper'

module Api
  module V2
    class IndexTest < ActionDispatch::IntegrationTest
      include ::ApiTestHelpers

      test 'GET #index without token is to render :unauthorized payload' do
        get api_v2_sectors_path
        documents_as(endpoint: :'v2/sectors/index', state: :unauthorized) do
          assert_response :unauthorized
          assert_equal 'UNAUTHORIZED', json_code
          assert_equal 'wrong api token', json_error
        end
      end

      test 'GET #index returns sectors' do
        user_1 = create(:user_operator)
        create(:sector, name: 'Agriculture')
        create(:sector, name: 'Agroalimentaire')
        create(:sector, name: 'Architecture')

        documents_as(endpoint: :'v2/sectors/index', state: :success) do
          get api_v2_sectors_path(
            params: {
              token: "Bearer #{user_1.api_token}"
            }
          )
          assert_response :success
          assert_equal 3, json_response['sectors'].count
        end
      end

      test 'GET #index returns too many requests after max calls limit' do
        skip 'Works locally but not always on CI' if ENV['CI'] == 'true'
        InternshipOffers::Api.const_set('MAX_CALLS_PER_MINUTE', 5)
        user_1 = create(:user_operator)
        create(:sector, name: 'Agriculture')
        create(:sector, name: 'Agroalimentaire')
        create(:sector, name: 'Architecture')

        documents_as(endpoint: :'v2/sectors/index', state: :too_many_requests) do
          (InternshipOffers::Api::MAX_CALLS_PER_MINUTE + 1).times do
            get api_v2_sectors_path(
              params: {
                token: "Bearer #{user_1.api_token}"
              }
            )
          end

          assert_response :too_many_requests
          assert_equal 'Trop de requêtes - Limite d\'utilisation de l\'API dépassée.', json_error
        end
      end
    end
  end
end
