# frozen_string_literal: true

require 'test_helper'

module Api
  module V2
    class SearchTest < ActionDispatch::IntegrationTest
      include ::ApiTestHelpers

      setup do
        @operator = create(:user_operator, :fully_authorized)
        post api_v2_auth_login_path(email: @operator.email, password: @operator.password)
        @token = json_response['token']
      end

      test 'GET #search without token renders :unauthorized payload' do
        get search_api_v2_internship_offers_path(params: {})
        documents_as(endpoint: :'internship_offers/search', state: :unauthorized) do
          assert_response :unauthorized
          assert_equal 'UNAUTHORIZED', json_code
          assert_equal 'wrong api token', json_error
        end
      end

      test 'GET #search without api_full_access renders :unauthorized payload' do
        @operator.operator.update(api_full_access: false)

        documents_as(endpoint: :'v2/internship_offers/search', state: :unauthorized) do
          get search_api_v2_internship_offers_path(
            params: {
              token: "Bearer #{@token}"
            }
          )

          assert_response :unauthorized
          assert_equal 'UNAUTHORIZED', json_code
          assert_equal 'access denied', json_error
        end
      end

      test 'GET #search without params returns all internship_offers available' do
        travel_to(Date.new(2025, 3, 1)) do
          # new token
          post api_v2_auth_login_path(email: @operator.email, password: @operator.password)
          @token = json_response['token']

          offer_1 = create(:weekly_internship_offer_2nde, coordinates: Coordinates.tours, city: 'Tours')
          offer_2 = create(:weekly_internship_offer_2nde, coordinates: Coordinates.paris, city: 'Paris',
                                                          remote_id: 'paris_id')
          offer_3 = create(:weekly_internship_offer_2nde, :unpublished, coordinates: Coordinates.bordeaux,
                                                                        city: 'Bordeaux')

          documents_as(endpoint: :'v2/internship_offers/search', state: :success) do
            get search_api_v2_internship_offers_path(
              params: {
                token: "Bearer #{@token}"
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
            assert_equal 'paris_id', json_response['internshipOffers'][0]['remote_id']
          end
        end
      end
      test 'GET #search with weeks params returns all internship_offers available on the given weeks' do
        travel_to(Date.new(2025, 3, 1)) do
          post api_v2_auth_login_path(email: @operator.email, password: @operator.password)
          @token = json_response['token']

          offer_3_1 = create(:weekly_internship_offer_3eme, coordinates: Coordinates.tours, city: 'Tours')
          offer_3_2 = create(:weekly_internship_offer_3eme, coordinates: Coordinates.paris, city: 'Paris')
          offer_2_1 = create(:weekly_internship_offer_2nde, coordinates: Coordinates.bordeaux, city: 'Bordeaux') # not available on the given weeks

          documents_as(endpoint: :'v2/internship_offers/search', state: :success) do
            get search_api_v2_internship_offers_path(
              params: {
                token: "Bearer #{@token}",
                weeks: %w[2025-W14 2025-W15] # 2025-W14-2025-W15 are weeks from 2025-03-17 to 2025-03-31
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
      test 'GET #search with june weeks params returns all internship_offers available on the given weeks' do
        travel_to(Date.new(2025, 3, 1)) do
          post api_v2_auth_login_path(email: @operator.email, password: @operator.password)
          @token = json_response['token']

          offer_3_1 = create(:weekly_internship_offer_3eme, coordinates: Coordinates.tours, city: 'Tours') # not available on the given weeks
          offer_3_2 = create(:weekly_internship_offer_3eme, coordinates: Coordinates.paris, city: 'Paris') # not available on the given weeks
          offer_2_1 = create(:weekly_internship_offer_2nde, coordinates: Coordinates.bordeaux, city: 'Bordeaux')

          documents_as(endpoint: :'v2/internship_offers/search', state: :success) do
            get search_api_v2_internship_offers_path(
              params: {
                token: "Bearer #{@token}",
                weeks: %w[2025-W25] # 2025-W25 is week from 2025-06-15 to 2025-06-21
              }
            )

            assert_response :success
            assert_equal 1, json_response['internshipOffers'].count
            assert_equal 1, json_response['pagination']['totalInternshipOffers']
            assert_equal 1, json_response['pagination']['totalPages']
            assert_equal true, json_response['pagination']['isFirstPage']
            # since api order is id: :desc
            assert_equal 'Bordeaux', json_response['internshipOffers'][0]['city']
          end
        end
      end
      test 'GET #search with keyword params returns all internship_offers available' do
        travel_to(Date.new(2025, 3, 1)) do
          post api_v2_auth_login_path(email: @operator.email, password: @operator.password)
          @token = json_response['token']

          offer_3_1 = create(:weekly_internship_offer_3eme, title: 'Avocat', coordinates: Coordinates.tours,
                                                            city: 'Tours')
          offer_3_2 = create(:weekly_internship_offer_3eme, title: 'Menuisier', coordinates: Coordinates.paris, city: 'Paris') # not displayed
          offer_2_1 = create(:weekly_internship_offer_2nde, title: 'Pharmacienne', coordinates: Coordinates.bordeaux, city: 'Bordeaux') # not displayed

          documents_as(endpoint: :'v2/internship_offers/search', state: :success) do
            get search_api_v2_internship_offers_path(
              params: {
                token: "Bearer #{@token}",
                keyword: 'Avocat'
              }
            )

            assert_response :success
            assert_equal 1, json_response['internshipOffers'].count
            assert_equal 1, json_response['pagination']['totalInternshipOffers']
            assert_equal 1, json_response['pagination']['totalPages']
            assert_equal true, json_response['pagination']['isFirstPage']
            # since api order is id: :desc
            assert_equal 'Tours', json_response['internshipOffers'][0]['city']
          end
        end
      end
      test 'GET #search with Paris geo params returns all internship_offers available' do
        travel_to(Date.new(2025, 3, 1)) do
          post api_v2_auth_login_path(email: @operator.email, password: @operator.password)
          @token = json_response['token']

          offer_3_1 = create(:weekly_internship_offer_3eme, coordinates: Coordinates.tours, city: 'Tours') # not displayed
          offer_3_2 = create(:weekly_internship_offer_3eme, coordinates: Coordinates.paris, city: 'Paris')
          offer_2_1 = create(:weekly_internship_offer_2nde, coordinates: Coordinates.bordeaux, city: 'Bordeaux') # not displayed

          documents_as(endpoint: :'internship_offers/search', state: :success) do
            get search_api_v2_internship_offers_path(
              params: {
                token: "Bearer #{@token}",
                latitude: 48.8566,
                longitude: 2.3522
              }
            )

            assert_response :success
            assert_equal 1, json_response['internshipOffers'].count
            assert_equal 1, json_response['pagination']['totalInternshipOffers']
            assert_equal 1, json_response['pagination']['totalPages']
            assert_equal true, json_response['pagination']['isFirstPage']
            # since api order is id: :desc
            assert_equal 'Paris', json_response['internshipOffers'][0]['city']
          end
        end
      end
      test 'GET #search with sector_ids params returns all internship_offers available' do
        travel_to(Date.new(2025, 3, 1)) do
          post api_v2_auth_login_path(email: @operator.email, password: @operator.password)
          @token = json_response['token']

          s1 = create(:sector, name: 'Hôtellerie')
          s2 = create(:sector, name: 'Restauration')
          s3 = create(:sector, name: 'Administration publique')

          offer_3_1 = create(:weekly_internship_offer_3eme, sector: s1, coordinates: Coordinates.tours, city: 'Tours') # not displayed
          offer_3_2 = create(:weekly_internship_offer_3eme, sector: s2, coordinates: Coordinates.paris,
                                                            city: 'Paris')
          offer_2_1 = create(:weekly_internship_offer_2nde, sector: s3, coordinates: Coordinates.bordeaux, city: 'Bordeaux') # not displayed

          documents_as(endpoint: :'v2/internship_offers/search', state: :success) do
            get search_api_v2_internship_offers_path(
              params: {
                token: "Bearer #{@token}",
                sectors: [s2.uuid]
              }
            )

            assert_response :success
            assert_equal 1, json_response['internshipOffers'].count
            assert_equal 1, json_response['pagination']['totalInternshipOffers']
            assert_equal 1, json_response['pagination']['totalPages']
            assert_equal true, json_response['pagination']['isFirstPage']
            # since api order is id: :desc
            assert_equal 'Paris', json_response['internshipOffers'][0]['city']
          end
        end
      end

      test 'GET #search with page params returns the page results' do
        travel_to Date.new(2025, 3, 1) do
          post api_v2_auth_login_path(email: @operator.email, password: @operator.password)
          @token = json_response['token']
          (InternshipOffer::PAGE_SIZE + 1).times { create(:weekly_internship_offer_2nde) }

          documents_as(endpoint: :'v2/internship_offers/search', state: :success) do
            get search_api_v2_internship_offers_path(
              params: {
                token: "Bearer #{@token}",
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
        travel_to Date.new(2025, 3, 1) do
          post api_v2_auth_login_path(email: @operator.email, password: @operator.password)
          @token = json_response['token']

          (InternshipOffer::PAGE_SIZE + 1).times { create(:weekly_internship_offer_2nde) }

          documents_as(endpoint: :'v2/internship_offers/search', state: :success) do
            get search_api_v2_internship_offers_path(
              params: {
                token: "Bearer #{@token}",
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
          post api_v2_auth_login_path(email: @operator.email, password: @operator.password)
          @token = json_response['token']

          offer_1 = create(:weekly_internship_offer_2nde, city: 'Bordeaux',
                                                          coordinates: { latitude: 44.8624, longitude: -0.5848 })
          offer_2 = create(:weekly_internship_offer_2nde)
          offer_3 = create(:weekly_internship_offer_2nde, :unpublished)

          documents_as(endpoint: :'v2/internship_offers/search', state: :success) do
            get search_api_v2_internship_offers_path(
              params: {
                token: "Bearer #{@token}",
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
          post api_v2_auth_login_path(email: @operator.email, password: @operator.password)
          @token = json_response['token']

          offer_1 = create(:weekly_internship_offer_2nde, city: 'Bordeaux',
                                                          coordinates: { latitude: 44.8624, longitude: -0.5848 })
          offer_2 = create(:weekly_internship_offer_2nde, city: 'Le Bouscat',
                                                          coordinates: { latitude: 44.865, longitude: -0.6033 })
          offer_3 = create(:weekly_internship_offer_2nde, :unpublished)

          documents_as(endpoint: :'v2/internship_offers/search', state: :success) do
            get search_api_v2_internship_offers_path(
              params: {
                token: "Bearer #{@token}",
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
          post api_v2_auth_login_path(email: @operator.email, password: @operator.password)
          @token = json_response['token']

          offer_1 = create(:weekly_internship_offer_2nde, city: 'Bordeaux',
                                                          coordinates: { latitude: 44.8624, longitude: -0.5848 })
          offer_2 = create(:weekly_internship_offer_2nde, city: 'Le Bouscat',
                                                          coordinates: { latitude: 44.865, longitude: -0.6033 })
          offer_3 = create(:weekly_internship_offer_2nde, :unpublished)

          documents_as(endpoint: :'v2/internship_offers/search', state: :success) do
            get search_api_v2_internship_offers_path(
              params: {
                token: "Bearer #{@token}",
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
          post api_v2_auth_login_path(email: @operator.email, password: @operator.password)
          @token = json_response['token']

          offer_1 = create(:weekly_internship_offer_2nde, title: 'Chef de chantier')
          offer_2 = create(:weekly_internship_offer_2nde, title: 'Avocat')
          offer_3 = create(:weekly_internship_offer_2nde, title: 'Cheffe de cuisine')

          documents_as(endpoint: :'v2/internship_offers/search', state: :success) do
            get search_api_v2_internship_offers_path(
              params: {
                token: "Bearer #{@token}",
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
        skip 'works locally but not on CI' if ENV['CI'] == 'true'
        post api_v2_auth_login_path(email: @operator.email, password: @operator.password)
        @token = json_response['token']

        InternshipOffers::Api.const_set('MAX_CALLS_PER_MINUTE', 5)
        (InternshipOffers::Api::MAX_CALLS_PER_MINUTE + 1).times do
          get search_api_v2_internship_offers_path(
            params: {
              token: "Bearer #{@token}"
            }
          )
        end
        get search_api_v2_internship_offers_path(
          params: {
            token: "Bearer #{@token}"
          }
        )
        InternshipOffers::Api.const_set('MAX_CALLS_PER_MINUTE', 1_000)

        documents_as(endpoint: :'v2/internship_offers/search', state: :too_many_requests) do
          assert_response :too_many_requests
          assert_equal 'Trop de requêtes - Limite d\'utilisation de l\'API dépassée.', json_error
        end
      end
    end
  end
end
