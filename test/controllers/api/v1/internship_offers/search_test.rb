# frozen_string_literal: true

require 'test_helper'

module Api
  module V1
    class SearchTest < ActionDispatch::IntegrationTest
      include ::ApiTestHelpers

      test 'GET #search without token renders :unauthorized payload' do
        get search_api_v1_internship_offers_path(params: {})
        documents_as(endpoint: :'internship_offers/search', state: :unauthorized) do
          assert_response :unauthorized
          assert_equal 'UNAUTHORIZED', json_code
          assert_equal 'wrong api token', json_error
        end
      end

      test 'GET #search without api_full_access renders :unauthorized payload' do
        user = create(:user_operator)
        operator = user.operator.update(api_full_access: false)

        documents_as(endpoint: :'internship_offers/search', state: :unauthorized) do
          get search_api_v1_internship_offers_path(
            params: {
              token: "Bearer #{user.api_token}"
            }
          )

          assert_response :unauthorized
          assert_equal 'UNAUTHORIZED', json_code
          assert_equal 'access denied', json_error
        end
      end

      test 'GET #search without params returns all internship_offers available' do
        travel_to(Date.new(2025, 3, 1)) do
          user = create(:user_operator, :fully_authorized)
          offer_1 = create(:weekly_internship_offer_2nde, coordinates: Coordinates.tours, city: 'Tours')
          offer_2 = create(:weekly_internship_offer_2nde, coordinates: Coordinates.paris, city: 'Paris')
          offer_3 = create(:weekly_internship_offer_2nde, :unpublished, coordinates: Coordinates.bordeaux,
                                                                        city: 'Bordeaux')

          documents_as(endpoint: :'internship_offers/search', state: :success) do
            get search_api_v1_internship_offers_path(
              params: {
                token: "Bearer #{user.api_token}"
              }
            )

            assert_response :success
            assert_equal 2, json_response['internshipOffers'].count
            assert_equal 2, json_response['pagination']['totalInternshipOffers']
            assert_equal 1, json_response['pagination']['totalPages']
            assert_equal true, json_response['pagination']['isFirstPage']
            # since api order is id: :desc
            assert_equal 'Paris', json_response['internshipOffers'][0]['city']
            assert_equal 'Tours', json_response['internshipOffers'][1]['city']
          end
        end
      end

      test 'GET #search with page params returns the page results' do
        user = create(:user_operator, :fully_authorized)
        travel_to Date.new(2025, 3, 1) do
          (InternshipOffer::PAGE_SIZE + 1).times { create(:weekly_internship_offer_2nde) }

          documents_as(endpoint: :'internship_offers/search', state: :success) do
            get search_api_v1_internship_offers_path(
              params: {
                token: "Bearer #{user.api_token}",
                page: 2
              }
            )

            assert_response :success
            assert_equal 1, json_response['internshipOffers'].count
            assert_equal InternshipOffer::PAGE_SIZE + 1, json_response['pagination']['totalInternshipOffers']
            assert_equal 2, json_response['pagination']['totalPages']
          end
        end
      end

      test 'GET #search with big page number params returns empty results' do
        travel_to Date.new(2025, 1, 1) do
          user = create(:user_operator, :fully_authorized)
          (InternshipOffer::PAGE_SIZE + 1).times { create(:weekly_internship_offer_2nde) }

          documents_as(endpoint: :'internship_offers/search', state: :success) do
            get search_api_v1_internship_offers_path(
              params: {
                token: "Bearer #{user.api_token}",
                page: 9
              }
            )

            assert_response :success
            assert_equal 0, json_response['internshipOffers'].count
            assert_equal InternshipOffer::PAGE_SIZE + 1, json_response['pagination']['totalInternshipOffers']
            assert_equal 2, json_response['pagination']['totalPages']
          end
        end
      end

      test 'GET #search with coordinates params returns all internship_offers available in the city' do
        travel_to(Date.new(2025, 3, 1)) do
          user = create(:user_operator, :fully_authorized)
          offer_1 = create(:weekly_internship_offer_2nde, city: 'Bordeaux',
                                                          coordinates: { latitude: 44.8624, longitude: -0.5848 })
          offer_2 = create(:weekly_internship_offer_2nde)
          offer_3 = create(:weekly_internship_offer_2nde, :unpublished)

          documents_as(endpoint: :'internship_offers/search', state: :success) do
            get search_api_v1_internship_offers_path(
              params: {
                token: "Bearer #{user.api_token}",
                latitude: 44.8624,
                longitude: -0.5848
              }
            )

            assert_response :success
            assert_equal 1, json_response['internshipOffers'].count
            assert_equal 1, json_response['pagination']['totalInternshipOffers']
            assert_equal 1, json_response['pagination']['totalPages']
            assert_equal true, json_response['pagination']['isFirstPage']
            assert_equal offer_1.id, json_response['internshipOffers'][0]['id']
          end
        end
      end

      test 'GET #search with coordinates and radius params returns all internship_offers available in the radius' do
        travel_to(Date.new(2025, 3, 1)) do
          user = create(:user_operator, :fully_authorized)
          offer_1 = create(:weekly_internship_offer_2nde, city: 'Bordeaux',
                                                          coordinates: { latitude: 44.8624, longitude: -0.5848 })
          offer_2 = create(:weekly_internship_offer_2nde, city: 'Le Bouscat',
                                                          coordinates: { latitude: 44.865, longitude: -0.6033 })
          offer_3 = create(:weekly_internship_offer_2nde, :unpublished)

          documents_as(endpoint: :'internship_offers/search', state: :success) do
            get search_api_v1_internship_offers_path(
              params: {
                token: "Bearer #{user.api_token}",
                latitude: 44.8624,
                longitude: -0.5848,
                radius: 10_000
              }
            )

            assert_response :success
            assert_equal 2, json_response['internshipOffers'].count
            assert_equal 'Bordeaux', json_response['internshipOffers'][0]['city']
            assert_equal 'Le bouscat', json_response['internshipOffers'][1]['city']
          end
        end
      end

      test 'GET #search with coordinates and radius params returns all internship_offers available in the radis' do
        travel_to(Date.new(2025, 3, 1)) do
          user = create(:user_operator, :fully_authorized)
          offer_1 = create(:weekly_internship_offer_2nde, city: 'Bordeaux',
                                                          coordinates: { latitude: 44.8624, longitude: -0.5848 })
          offer_2 = create(:weekly_internship_offer_2nde, city: 'Le Bouscat',
                                                          coordinates: { latitude: 44.865, longitude: -0.6033 })
          offer_3 = create(:weekly_internship_offer_2nde, :unpublished)

          documents_as(endpoint: :'internship_offers/search', state: :success) do
            get search_api_v1_internship_offers_path(
              params: {
                token: "Bearer #{user.api_token}",
                latitude: 44.8624,
                longitude: -0.5848,
                radius: 1
              }
            )

            assert_response :success
            assert_equal 1, json_response['internshipOffers'].count
            assert_equal offer_1.id, json_response['internshipOffers'][0]['id']
          end
        end
      end

      test 'GET #search with keyword params returns all internship_offers available in the radis' do
        travel_to(Date.new(2025, 3, 1)) do
          user = create(:user_operator, :fully_authorized)
          offer_1 = create(:weekly_internship_offer_2nde, title: 'Chef de chantier')
          offer_2 = create(:weekly_internship_offer_2nde, title: 'Avocat')
          offer_3 = create(:weekly_internship_offer_2nde, title: 'Cheffe de cuisine')

          documents_as(endpoint: :'internship_offers/search', state: :success) do
            get search_api_v1_internship_offers_path(
              params: {
                token: "Bearer #{user.api_token}",
                keyword: 'cuisine'
              }
            )

            assert_response :success
            assert_equal 1, json_response['internshipOffers'].count
            assert_equal offer_3.id, json_response['internshipOffers'][0]['id']
          end
        end
      end

      test 'GET #search returns too many requests after max calls limit' do
        skip 'Works locally but not always on CI' if ENV['CI'] == 'true'
        if ENV.fetch('TEST_WITH_MAX_REQUESTS_PER_MINUTE', false) == 'true'
          user = create(:user_operator, :fully_authorized)

          original_max_calls = InternshipOffers::Api::MAX_CALLS_PER_MINUTE
          InternshipOffers::Api::MAX_CALLS_PER_MINUTE = 5

          begin
            (InternshipOffers::Api::MAX_CALLS_PER_MINUTE + 1).times do
              get search_api_v1_internship_offers_path(
                params: {
                  token: "Bearer #{user.api_token}"
                }
              )
            end
            get search_api_v1_internship_offers_path(
              params: {
                token: "Bearer #{user.api_token}"
              }
            )

            documents_as(endpoint: :'internship_offers/search', state: :too_many_requests) do
              assert_response :too_many_requests
              assert_equal 'Trop de requêtes - Limite d\'utilisation de l\'API dépassée.', json_error
            end
          ensure
            InternshipOffers::Api::MAX_CALLS_PER_MINUTE = original_max_calls
            # end
          end
        end
      end
    end
  end
end
