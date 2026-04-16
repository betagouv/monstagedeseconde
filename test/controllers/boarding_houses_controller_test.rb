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

  test 'GET search with lat/long filters by radius — excludes houses outside the radius' do
    bordeaux_academy = Department.fetch_by_zipcode(zipcode: '33000')&.academy || create(:academy)
    bh_paris = create(:boarding_house, coordinates: Coordinates.paris)
    create(:boarding_house, academy: bordeaux_academy, zipcode: '33000',
                            city: 'Bordeaux', coordinates: Coordinates.bordeaux)

    get boarding_houses_search_path, params: {
      latitude: Coordinates.paris[:latitude],
      longitude: Coordinates.paris[:longitude],
      radius: 50_000
    }, as: :json

    assert_response :success
    json = JSON.parse(response.body)
    assert_equal 1, json['boardingHouses'].size
    assert_equal bh_paris.id, json['boardingHouses'].first['id']
  end

  test 'GET search without lat/long returns all boarding houses regardless of count (no pagination)' do
    30.times { |i| create(:boarding_house, name: "Internat ##{i}", coordinates: Coordinates.paris) }

    get boarding_houses_search_path, as: :json

    assert_response :success
    json = JSON.parse(response.body)
    assert_operator json['boardingHouses'].size, :>=, 30
  end
end
