# frozen_string_literal: true

require 'test_helper'

class BoardingHouseViewTest < ActiveSupport::TestCase
  test 'requires a boarding house' do
    view = BoardingHouseView.new
    assert_not view.valid?
    assert view.errors[:boarding_house].any?
  end

  test 'persists with anonymous user' do
    bh = create(:boarding_house, coordinates: Coordinates.paris)
    view = BoardingHouseView.create!(boarding_house: bh, latitude: 48.8, longitude: 2.3, radius: 60_000)
    assert_nil view.user_id
    assert_equal bh.id, view.boarding_house_id
  end

  test 'persists with a signed-in user' do
    bh = create(:boarding_house, coordinates: Coordinates.paris)
    student = create(:student)
    view = BoardingHouseView.create!(boarding_house: bh, user: student)
    assert_equal student.id, view.user_id
  end
end
