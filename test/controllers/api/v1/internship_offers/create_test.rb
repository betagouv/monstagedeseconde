# frozen_string_literal: true

require 'test_helper'

module Api
  module V1
    class CreateTest < ActionDispatch::IntegrationTest
      include ::ApiTestHelpers

      # before each test
      test 'POST #create without token renders :unauthorized payload' do
        post api_v1_internship_offers_path(params: {})
        documents_as(endpoint: :'internship_offers/create', state: :unauthorized) do
          assert_response :unauthorized
          assert_equal 'UNAUTHORIZED', json_code
          assert_equal 'wrong api token', json_error
        end
      end

      test 'POST #create as operator fails with invalid payload respond with :unprocessable_entity' do
        operator = create(:user_operator, api_token: SecureRandom.uuid)
        documents_as(endpoint: :'internship_offers/create', state: :unprocessable_entity_bad_payload) do
          post api_v1_internship_offers_path(
            params: {
              token: "Bearer #{operator.api_token}"
            }
          )
        end
        assert_response :unprocessable_entity
        assert_equal 'BAD_PAYLOAD', json_code
        assert_equal 'param is missing or the value is empty: internship_offer', json_error
      end

      test 'POST #create as operator fails with invalid data respond with :bad_request' do
        operator = create(:user_operator, api_token: SecureRandom.uuid)
        documents_as(endpoint: :'internship_offers/create', state: :bad_request) do
          post api_v1_internship_offers_path(
            params: {
              token: "Bearer #{operator.api_token}",
              internship_offer: { title: '' }
            }
          )
        end
        assert_response :bad_request
        assert_equal 'VALIDATION_ERROR', json_code
        assert_equal ['Missing title'],
                     json_error['title'],
                     'bad title message'
        assert_equal ['Missing employer_name'],
                     json_error['employer_name'],
                     'bad employer_name message'
        assert_equal ['Missing zipcode', 'is invalid'],
                     json_error['zipcode'],
                     'bad zipcode message'
        assert_equal ['Missing city'],
                     json_error['city'],
                     'bad city message'
        assert_equal ['Missing remote_id'],
                     json_error['remote_id'],
                     'bad remote_id message'
        assert_equal ['Missing sector'],
                     json_error['sector'],
                     'bad sector message'
      end

      test 'POST #create as operator post duplicate remote_id' do
        operator = create(:user_operator, api_token: SecureRandom.uuid)
        existing_internship_offer = create(:api_internship_offer_2nde, employer: operator)
        sector = create(:sector, uuid: SecureRandom.uuid)
        internship_offer_params = existing_internship_offer.attributes
                                                           .except(:sector,
                                                                   :coordinates)
                                                           .merge(sector_uuid: sector.uuid,
                                                                  coordinates: { latitude: 1, longitude: 1 })

        geocoder_response = {
          status: 200,
          body: [{
            "address": { "office": "Ministère de l'Éducation Nationale", "road": 'Rue de Grenelle', "suburb": '',
                         "city_district": '7th Arrondissement', "city": 'Paris', "municipality": 'Paris', "county": 'Paris', "country": 'France', "postcode": '75002', "country_code": 'fr' },
            "lat": 1,
            "lon": 1
          }].to_json
        }
        stub_request(:get, 'https://nominatim.openstreetmap.org/search?accept-language=en&addressdetails=1&format=json&q=75001,%20France').to_return(geocoder_response)

        documents_as(endpoint: :'internship_offers/create', state: :conflict) do
          post api_v1_internship_offers_path(
            params: {
              token: "Bearer #{operator.api_token}",
              internship_offer: internship_offer_params
            }
          )
        end
        assert_response :conflict
      end

      test 'POST #create as operator works to internship_offers' do
        operator = create(:user_operator, api_token: SecureRandom.uuid)
        sector = Sector.find_by(name: 'Fonction publique')
        title = 'title'
        description = 'description'
        employer_name = 'employer_name'
        employer_description = 'employer_description'
        employer_website = 'http://google.fr'
        coordinates = { latitude: 1, longitude: 1 }
        street = "Avenue de l'opéra"
        zipcode = '75002'
        city = 'Paris'
        siret = FFaker::CompanyFR.siret
        sector_uuid = sector.uuid
        remote_id = 'test'
        permalink = 'http://monsite.com'
        daily_hours = { "lundi": ['9:00', '17:00'], "mardi": ['9:00', '17:00'], "mercredi": ['9:00', '17:00'],
                        "jeudi": ['9:00', '17:00'], "vendredi": ['9:00', '17:00'] }
        assert_difference('InternshipOffer.count', 1) do
          documents_as(endpoint: :'internship_offers/create', state: :created) do
            post api_v1_internship_offers_path(
              params: {
                token: "Bearer #{operator.api_token}",
                internship_offer: {
                  title:,
                  description:,
                  employer_name:,
                  employer_description:,
                  employer_website:,
                  siret:,
                  'coordinates' => coordinates,
                  street:,
                  zipcode:,
                  city:,
                  sector_uuid:,
                  remote_id:,
                  max_candidates: 2,
                  is_public: true,
                  daily_hours:,
                  permalink:,
                  lunch_break: 'Repas sur place'
                }
              }
            )
          end
          assert_response :created
        end

        internship_offer = InternshipOffers::Api.first
        assert_equal title, internship_offer.title
        assert_equal description, internship_offer.description
        assert_equal employer_name, internship_offer.employer_name
        assert_equal employer_description, internship_offer.employer_description
        assert_equal 0, internship_offer.period
        assert_equal employer_website, internship_offer.employer_website
        assert_equal coordinates, latitude: internship_offer.coordinates.latitude,
                                  longitude: internship_offer.coordinates.longitude
        assert_equal street, internship_offer.street
        assert_equal zipcode, internship_offer.zipcode
        assert_equal city, internship_offer.city

        assert_equal sector, internship_offer.sector
        assert_equal remote_id, internship_offer.remote_id
        assert_equal 2, internship_offer.max_candidates
        assert_equal 2, internship_offer.remaining_seats_count
        assert_equal 'published', internship_offer.aasm_state
        assert internship_offer.is_public
        assert_equal false, internship_offer.handicap_accessible
        assert_equal daily_hours[:lundi], internship_offer.daily_hours['lundi']
        assert_equal daily_hours[:mardi], internship_offer.daily_hours['mardi']
        assert_equal daily_hours[:mercredi], internship_offer.daily_hours['mercredi']
        assert_equal daily_hours[:jeudi], internship_offer.daily_hours['jeudi']
        assert_equal daily_hours[:vendredi], internship_offer.daily_hours['vendredi']
        assert_equal 'Repas sur place', internship_offer.lunch_break
        assert_equal 0, internship_offer.period # default value 2 weeks
        assert_equal [Grade.seconde], internship_offer.grades # default value seconde

        assert_equal JSON.parse(internship_offer.to_json), json_response
      end

      # TO DO : fix this redirect
      # test 'POST #create without api version as operator works to create internship_offers' do
      #   operator = create(:user_operator, api_token: SecureRandom.uuid)
      #   sector = create(:sector, uuid: SecureRandom.uuid)
      #   title = 'title'
      #   description = 'description'
      #   employer_name = 'employer_name'
      #   employer_description = 'employer_description'
      #   employer_website = 'http://google.fr'
      #   coordinates = { latitude: 1, longitude: 1 }
      #   street = "Avenue de l'opéra"
      #   zipcode = '75002'
      #   city = 'Paris'
      #   siret = FFaker::CompanyFR.siret
      #   sector_uuid = sector.uuid
      #   remote_id = 'test'
      #   permalink = 'http://monsite.com'
      #   daily_hours = { "lundi": ['9:00', '17:00'], "mardi": ['9:00', '17:00'], "mercredi": ['9:00', '17:00'],
      #                   "jeudi": ['9:00', '17:00'], "vendredi": ['9:00', '17:00'] }
      #   # assert_difference('InternshipOffer.count', 1) do
      #   documents_as(endpoint: :'internship_offers/create', state: :created) do
      #     post '/api/internship_offers',
      #          params: {
      #            token: "Bearer #{operator.api_token}",
      #            internship_offer: {
      #              title:,
      #              description:,
      #              employer_name:,
      #              employer_description:,
      #              employer_website:,
      #              siret:,
      #              'coordinates' => coordinates,
      #              street:,
      #              zipcode:,
      #              city:,
      #              sector_uuid:,
      #              remote_id:,
      #              max_candidates: 2,
      #              is_public: true,
      #              daily_hours:,
      #              permalink:,
      #              lunch_break: 'Repas sur place'
      #            }
      #          }
      #   end
      #   assert_response :redirect
      #   # end

      #   internship_offer = InternshipOffers::Api.first
      #   assert_equal 1, InternshipOffers::Api.count
      #   assert_equal title, internship_offer.title
      # end

      test 'POST #create when missing coordinates works to create internship_offers' do
        operator = create(:user_operator, api_token: SecureRandom.uuid)
        sector = create(:sector, uuid: SecureRandom.uuid)
        title = 'title'
        description = 'description'
        period = 1 # week 1
        coordinates = { latitude: 48.8602244, longitude: 2.333 }
        employer_name = 'employer_name'
        employer_description = 'employer_description'
        employer_website = 'http://google.fr'
        street = "Avenue de l'opéra"
        zipcode = '75002'
        city = 'Paris'
        siret = FFaker::CompanyFR.siret
        sector_uuid = sector.uuid
        remote_id = 'test'
        permalink = 'http://monsite.com'

        geocoder_response = {
          status: 200,
          body: [{
            "address": { "office": "Ministère de l'Éducation Nationale", "road": 'Rue de Grenelle', "suburb": '',
                         "city_district": '7th Arrondissement', "city": 'Paris', "municipality": 'Paris', "county": 'Paris', "country": 'France', "postcode": '75002', "country_code": 'fr' },
            "lat": coordinates[:latitude],
            "lon": coordinates[:longitude]
          }].to_json
        }
        stub_request(:get, 'https://nominatim.openstreetmap.org/search?accept-language=en&addressdetails=1&format=json&q=75002,%20France').to_return(geocoder_response)

        assert_difference('InternshipOffer.count', 1) do
          documents_as(endpoint: :'internship_offers/create', state: :created) do
            post api_v1_internship_offers_path(
              params: {
                token: "Bearer #{operator.api_token}",
                internship_offer: {
                  title:,
                  description:,
                  employer_name:,
                  employer_description:,
                  employer_website:,
                  siret:,
                  street:,
                  zipcode:,
                  city:,
                  sector_uuid:,
                  remote_id:,
                  max_candidates: 2,
                  period:,
                  permalink:,
                  handicap_accessible: true
                }
              }
            )
          end
          assert_response :created
        end

        internship_offer = InternshipOffers::Api.first
        assert_equal title, internship_offer.title
        assert_equal false, internship_offer.is_public
        assert_equal 1, internship_offer.period
        assert_equal coordinates[:latitude], internship_offer.coordinates.latitude
        assert_equal coordinates[:longitude], internship_offer.coordinates.longitude
        assert_equal JSON.parse(internship_offer.to_json), json_response
        assert_equal true, internship_offer.handicap_accessible
      end

      test 'POST #create as operator without max_candidates works and set up remaing_seats_count to 1' do
        operator = create(:user_operator, api_token: SecureRandom.uuid)
        week_instances = [weeks(:week_2025_1), weeks(:week_2025_2)]
        sector = create(:sector, uuid: SecureRandom.uuid)
        title = 'title'
        description = 'description'
        period = 2 # week 2
        employer_name = 'employer_name'
        employer_description = 'employer_description'
        employer_website = 'http://google.fr'
        coordinates = { latitude: 1, longitude: 1 }
        street = "Avenue de l'opéra"
        zipcode = '75002'
        city = 'Paris'
        siret = FFaker::CompanyFR.siret
        sector_uuid = sector.uuid
        remote_id = 'test'
        permalink = 'http://monsite.com'
        weeks = Week.selectable_from_now_until_end_of_school_year + SchoolTrack::Seconde.both_weeks

        assert_difference('InternshipOffer.count', 1) do
          documents_as(endpoint: :'internship_offers/create', state: :created) do
            post api_v1_internship_offers_path(
              params: {
                token: "Bearer #{operator.api_token}",
                internship_offer: {
                  title:,
                  description:,
                  employer_name:,
                  employer_description:,
                  period:,
                  employer_website:,
                  siret:,
                  coordinates:,
                  street:,
                  zipcode:,
                  city:,
                  sector_uuid:,
                  remote_id:,
                  permalink:,
                  weeks:
                }
              }
            )
          end
          assert_response :created
        end

        internship_offer = InternshipOffers::Api.first
        assert_equal 1, internship_offer.max_candidates
        assert_equal 1, internship_offer.remaining_seats_count
        assert_equal 2, internship_offer.period
      end

      test 'POST #create as operator with empty street creates the internship offer' do
        operator = create(:user_operator, api_token: SecureRandom.uuid)
        sector = create(:sector, uuid: SecureRandom.uuid)
        geocoder_response = {
          status: 200,
          body: [{
            "address": { "office": "Ministère de l'Éducation Nationale", "road": 'Rue de Grenelle',
                         "suburb": '7th Arrondissement', "city_district": '7th Arrondissement', "city": 'Paris', "municipality": 'Paris', "county": 'Paris', "country": 'France', "postcode": '75007', "country_code": 'fr' }
          }].to_json
        }
        stub_request(:get, 'https://nominatim.openstreetmap.org/reverse?accept-language=en&addressdetails=1&format=json&lat=48.8566383&lon=2.3211761').to_return(geocoder_response)

        travel_to(Date.new(2024, 3, 1)) do
          assert_difference('InternshipOffer.count', 1) do
            documents_as(endpoint: :'internship_offers/create', state: :unprocessable_entity_bad_data) do
              post api_v1_internship_offers_path(
                params: {
                  token: "Bearer #{operator.api_token}",
                  internship_offer: {
                    title: 'title',
                    description: 'description',
                    pediod: 0,
                    employer_name: 'Ministere',
                    employer_description: 'employer_description',
                    employer_website: 'http://employer_website.com',
                    coordinates: { latitude: 48.8566383, longitude: 2.3211761 },
                    street: '',
                    zipcode: '75007',
                    city: 'Paris',
                    sector_uuid: sector.uuid,
                    remote_id: 'remote_id',
                    permalink: 'http://monsite.com',
                    weeks: Week.selectable_from_now_until_end_of_school_year + SchoolTrack::Seconde.both_weeks
                  }
                }
              )
            end
            assert_response :created
          end
          internship_offer = InternshipOffers::Api.first
          assert_equal 'Rue de Grenelle', internship_offer.street
        end
      end

      test 'POST #create as operator with empty zipcode creates the internship offer' do
        operator = create(:user_operator, api_token: SecureRandom.uuid)
        sector = create(:sector, uuid: SecureRandom.uuid)
        geocoder_response = {
          status: 200,
          body: [{
            "address": { "office": "Ministère de l'Éducation Nationale", "road": 'Rue de Grenelle',
                         "suburb": '7th Arrondissement', "city_district": '7th Arrondissement', "city": 'Paris', "municipality": 'Paris', "county": 'Paris', "country": 'France', "postcode": '75007', "country_code": 'fr' }
          }].to_json
        }
        stub_request(:get, 'https://nominatim.openstreetmap.org/reverse?accept-language=en&addressdetails=1&format=json&lat=48.8566383&lon=2.3211761').to_return(geocoder_response)

        travel_to(Date.new(2024, 3, 1)) do
          assert_difference('InternshipOffer.count', 1) do
            documents_as(endpoint: :'internship_offers/create', state: :unprocessable_entity_bad_data) do
              post api_v1_internship_offers_path(
                params: {
                  token: "Bearer #{operator.api_token}",
                  internship_offer: {
                    title: 'title',
                    description: 'description',
                    employer_name: 'Ministere',
                    employer_description: 'employer_description',
                    pediod: 0,
                    employer_website: 'http://employer_website.com',
                    coordinates: { latitude: 48.8566383, longitude: 2.3211761 },
                    street: '',
                    zipcode: '',
                    siret: FFaker::CompanyFR.siret,
                    city: 'Paris',
                    sector_uuid: sector.uuid,
                    remote_id: 'remote_id',
                    permalink: 'http://monsite.com',
                    weeks: Week.selectable_from_now_until_end_of_school_year + SchoolTrack::Seconde.both_weeks
                  }
                }
              )
            end
            assert_response :created
          end
          internship_offer = InternshipOffers::Api.first
          assert_equal 'Rue de Grenelle', internship_offer.street
        end
      end

      test 'POST #create as operator with without street creates the internship offer' do
        operator = create(:user_operator, api_token: SecureRandom.uuid)
        sector = create(:sector, uuid: SecureRandom.uuid)
        geocoder_response = {
          status: 200,
          body: [{
            "address": { "office": "Ministère de l'Éducation Nationale", "road": 'Rue de Grenelle',
                         "suburb": '7th Arrondissement', "city_district": '7th Arrondissement', "city": 'Paris', "municipality": 'Paris', "county": 'Paris', "country": 'France', "postcode": '75007', "country_code": 'fr' }
          }].to_json
        }
        stub_request(:get, 'https://nominatim.openstreetmap.org/reverse?accept-language=en&addressdetails=1&format=json&lat=48.8566383&lon=2.3211761').to_return(geocoder_response)

        travel_to(Date.new(2024, 3, 1)) do
          assert_difference('InternshipOffer.count', 1) do
            documents_as(endpoint: :'internship_offers/create', state: :unprocessable_entity_bad_data) do
              post api_v1_internship_offers_path(
                params: {
                  token: "Bearer #{operator.api_token}",
                  internship_offer: {
                    title: 'title',
                    description: 'description',
                    pediod: 0,
                    employer_name: 'Ministere',
                    employer_description: 'employer_description',
                    employer_website: 'http://employer_website.com',
                    coordinates: { latitude: 48.8566383, longitude: 2.3211761 },
                    zipcode: '75007',
                    city: 'Paris',
                    siret: FFaker::CompanyFR.siret,
                    sector_uuid: sector.uuid,
                    remote_id: 'remote_id',
                    permalink: 'http://monsite.com',
                    weeks: Week.selectable_from_now_until_end_of_school_year + SchoolTrack::Seconde.both_weeks
                  }
                }
              )
            end
            assert_response :created
          end
          internship_offer = InternshipOffers::Api.first
          assert_equal 'Rue de Grenelle', internship_offer.street
        end
      end

      test 'POST #create as operator with wrong coordinates creates the internship offer with N/A street' do
        operator = create(:user_operator, api_token: SecureRandom.uuid)
        sector = create(:sector, uuid: SecureRandom.uuid)
        geocoder_response = {
          status: 200,
          body: [{ "error": 'wrong address' }].to_json
        }
        stub_request(:get, 'https://nominatim.openstreetmap.org/reverse?accept-language=en&addressdetails=1&format=json&lat=148&lon=14').to_return(geocoder_response)

        travel_to(Date.new(2024, 3, 1)) do
          assert_difference('InternshipOffer.count', 1) do
            documents_as(endpoint: :'internship_offers/create', state: :unprocessable_entity_bad_data) do
              post api_v1_internship_offers_path(
                params: {
                  token: "Bearer #{operator.api_token}",
                  internship_offer: {
                    title: 'title',
                    description: 'description',
                    pediod: 0,
                    employer_name: 'Ministere',
                    employer_description: 'employer_description',
                    employer_website: 'http://employer_website.com',
                    siret: FFaker::CompanyFR.siret,
                    coordinates: { latitude: 148, longitude: 14 },
                    zipcode: '75007',
                    city: 'Paris',
                    sector_uuid: sector.uuid,
                    remote_id: 'remote_id',
                    permalink: 'http://monsite.com',
                    weeks: Week.selectable_from_now_until_end_of_school_year + SchoolTrack::Seconde.both_weeks
                  }
                }
              )
            end
            assert_response :created
          end
          internship_offer = InternshipOffers::Api.first
          assert_equal 'N/A', internship_offer.street
        end
      end

      test 'POST #create as operator with not enough weeks does not fail' do
        operator = create(:user_operator, api_token: SecureRandom.uuid)
        sector = create(:sector, uuid: SecureRandom.uuid)
        geocoder_response = {
          status: 200,
          body: [{ "error": 'wrong address' }].to_json
        }
        stub_request(:get, 'https://nominatim.openstreetmap.org/reverse?accept-language=en&addressdetails=1&format=json&lat=148&lon=14').to_return(geocoder_response)

        travel_to(Date.new(2025, 3, 1)) do
          assert_difference('InternshipOffer.count', 1) do
            post api_v1_internship_offers_path(
              params: {
                token: "Bearer #{operator.api_token}",
                internship_offer: {
                  title: 'title',
                  description: 'description',
                  employer_name: 'Ministere',
                  employer_description: 'employer_description',
                  pediod: 0,
                  employer_website: 'http://employer_website.com',
                  siret: FFaker::CompanyFR.siret,
                  coordinates: { latitude: 148, longitude: 14 },
                  zipcode: '75007',
                  city: 'Paris',
                  sector_uuid: sector.uuid,
                  remote_id: 'remote_id',
                  max_candidates: 3,
                  permalink: 'http://monsite.com'
                }
              }
            )
          end

          assert_response :created
          internship_offer = InternshipOffers::Api.first
          assert_equal 3, internship_offer.remaining_seats_count
        end
      end
    end
  end
end
