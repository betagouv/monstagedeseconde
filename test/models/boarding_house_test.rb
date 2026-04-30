# frozen_string_literal: true

require 'test_helper'

class BoardingHouseTest < ActiveSupport::TestCase
  test 'valid boarding house' do
    boarding_house = build(:boarding_house)
    assert boarding_house.valid?
  end

  test 'invalid without name' do
    boarding_house = build(:boarding_house, name: nil)
    assert_not boarding_house.valid?
    assert boarding_house.errors[:name].any?
  end

  test 'invalid without zipcode' do
    boarding_house = build(:boarding_house, zipcode: nil)
    assert_not boarding_house.valid?
    assert boarding_house.errors[:zipcode].any?
  end

  test 'invalid without city' do
    boarding_house = build(:boarding_house, city: nil)
    assert_not boarding_house.valid?
    assert boarding_house.errors[:city].any?
  end

  test 'department is set automatically from zipcode' do
    boarding_house = build(:boarding_house, department: nil, zipcode: '75001')
    boarding_house.valid?
    assert_equal 'Paris', boarding_house.department
  end

  test 'invalid with negative available_places' do
    boarding_house = build(:boarding_house, available_places: -1)
    assert_not boarding_house.valid?
    assert boarding_house.errors[:available_places].any?
  end

  test 'belongs to academy' do
    boarding_house = build(:boarding_house)
    assert boarding_house.academy.present?
  end

  test 'nearby scope returns boarding houses within radius' do
    bh_paris = create(:boarding_house, coordinates: Coordinates.paris)
    bordeaux_academy = Department.fetch_by_zipcode(zipcode: '33000')&.academy || create(:academy)
    bh_bordeaux = create(:boarding_house, academy: bordeaux_academy, zipcode: '33000',
                                          city: 'Bordeaux', coordinates: Coordinates.bordeaux)

    nearby = BoardingHouse.nearby(
      latitude: Coordinates.paris[:latitude],
      longitude: Coordinates.paris[:longitude],
      radius: 50_000
    )

    assert_includes nearby, bh_paris
    assert_not_includes nearby, bh_bordeaux
  end
end
