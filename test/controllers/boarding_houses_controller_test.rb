# frozen_string_literal: true

require 'test_helper'

class BoardingHousesControllerTest < ActionDispatch::IntegrationTest
  test 'GET search returns boarding houses as JSON' do
    bh = create(:boarding_house, coordinates: Coordinates.paris)

    get boarding_houses_search_path, params: {
      latitude: Coordinates.paris[:latitude],
      longitude: Coordinates.paris[:longitude],
      radius: 60_000
    }, as: :json

    assert_response :success
    json = JSON.parse(response.body)
    assert json['boardingHouses'].any?
    assert_equal bh.name, json['boardingHouses'].first['name']
  end

  test 'GET search returns empty when no coordinates' do
    get boarding_houses_search_path, params: {
      latitude: 0,
      longitude: 0
    }, as: :json

    assert_response :success
    json = JSON.parse(response.body)
    assert_empty json['boardingHouses']
  end

  test 'GET search excludes boarding houses with 0 available places' do
    create(:boarding_house, coordinates: Coordinates.paris, available_places: 0)

    get boarding_houses_search_path, params: {
      latitude: Coordinates.paris[:latitude],
      longitude: Coordinates.paris[:longitude],
      radius: 60_000
    }, as: :json

    assert_response :success
    json = JSON.parse(response.body)
    assert_empty json['boardingHouses']
  end
end
