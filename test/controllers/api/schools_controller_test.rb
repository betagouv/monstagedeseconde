# frozen_string_literal: true

require 'test_helper'

module Api
  class SchoolsControllerTest < ActionDispatch::IntegrationTest
    include ::ApiTestHelpers

    test 'empty search or faulty search both works' do
      post search_api_v1_schools_path, params: {}
      assert_response :success
      assert_equal({ 'match_by_city' => {}, 'match_by_name' => [], 'no_match' => true }, json_response)

      post search_api_v1_schools_path, params: { term: 'eeeeeeeee' }
      assert_response :success
      assert_equal({ 'match_by_city' => {}, 'match_by_name' => [], 'no_match' => true }, json_response)
    end

    test 'POST#search with term works' do
      parisian_school = create(:api_school, city: 'Paris', zipcode: '75015')
      parisian_school.reload # ensure triggered city_tsv had been reloaded

      post search_api_v1_schools_path, params: { query: 'Paris' }
      parisian_schools_key = json_response.keys.first
      first_parisian_school = json_response[parisian_schools_key].first
    end

    test 'POST#nearby with lat/lng/radius' do
      school_at_bordeaux = create(:school, :at_bordeaux)
      school_at_paris = create(:school, :at_paris)
      post nearby_api_v1_schools_path, params: { latitude: Coordinates.bordeaux[:latitude],
                                                 longitude: Coordinates.bordeaux[:longitude] }
      assert_response :success
      found_school = json_response.first
    end

    # test 'constructor with a valid term' do
    #   autocomplete_school = Api::AutocompleteSchool.new(term: 'Paris', limit: 10)
    #   assert_equal 'dsds', autocomplete_school.result[:match_by_city]
    # end
  end
end
