# frozen_string_literal: true

require 'test_helper'

class BoardingHousesControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

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

  test 'POST track_view records a view for a signed-in user' do
    bh = create(:boarding_house, coordinates: Coordinates.paris)
    student = create(:student)
    sign_in(student)

    assert_difference -> { BoardingHouseView.count }, 1 do
      post boarding_house_track_view_path(bh), params: {
        latitude: Coordinates.paris[:latitude],
        longitude: Coordinates.paris[:longitude],
        radius: 60_000
      }
    end

    assert_response :no_content
    view = BoardingHouseView.last
    assert_equal bh.id, view.boarding_house_id
    assert_equal student.id, view.user_id
    assert_in_delta Coordinates.paris[:latitude], view.latitude, 0.0001
    assert_in_delta Coordinates.paris[:longitude], view.longitude, 0.0001
    assert_equal 60_000, view.radius
  end

  test 'POST track_view records a view for an anonymous visitor' do
    bh = create(:boarding_house, coordinates: Coordinates.paris)

    assert_difference -> { BoardingHouseView.count }, 1 do
      post boarding_house_track_view_path(bh)
    end

    assert_response :no_content
    assert_nil BoardingHouseView.last.user_id
  end

  test 'POST track_view returns 404 when boarding house does not exist' do
    assert_no_difference -> { BoardingHouseView.count } do
      post boarding_house_track_view_path(id: 0)
    end

    assert_response :not_found
  end
end
