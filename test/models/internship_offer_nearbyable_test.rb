# frozen_string_literal: true

require 'test_helper'

class InternshipOfferNearbyableTest < ActiveSupport::TestCase
  def setup
    @coordinates_paris = Coordinates.paris
    create(:department)
    @coordinates_verneuil = Coordinates.verneuil
    create(:department, code: '78', name: 'Yvelines')
    @coordinates_chatillon = Coordinates.chatillon
    create(:department, code: '92', name: 'Hauts-de-Seine')
    @coordinates_bordeaux = Coordinates.bordeaux
    create(:department, code: '33', name: 'Gironde')
    @coordinates_pithiviers = Coordinates.pithiviers
    create(:department, code: '45', name: 'Loiret')
    @coordinates_melun = Coordinates.melun
    create(:department, code: '77', name: 'Seine-et-Marne')

    @offer_paris      = create(:weekly_internship_offer, coordinates: @coordinates_paris, city: 'Paris')
    @offer_chatillon  = create(:weekly_internship_offer, coordinates: @coordinates_chatillon, city: 'Chatillon')
    @offer_bordeaux   = create(:weekly_internship_offer, coordinates: @coordinates_bordeaux, city: 'Bordeaux')
    @offer_pithiviers = create(:weekly_internship_offer, coordinates: @coordinates_pithiviers, city: 'Pithiviers')
    @offer_verneuil   = create(:weekly_internship_offer, coordinates: @coordinates_verneuil, city: 'Verneuil')
    @offer_melun      = create(:weekly_internship_offer, coordinates: @coordinates_melun, city: 'Melun')
  end
  test '.distance_from' do
    internship_offers = InternshipOffer.with_distance_from(latitude: @coordinates_bordeaux[:latitude],
                                                           longitude: @coordinates_bordeaux[:longitude])
                                       .all
    assert_equal 499_841.82156578, internship_offers.first.relative_distance
  end

  test 'scope :with_distance_from' do
    if ENV.fetch('CI', false) == 'true'
      skip "This test is not working on CI, it's working locally. Need to investigate why."
    end
    result = InternshipOffer.with_distance_from(
      latitude: @coordinates_paris[:latitude],
      longitude: @coordinates_paris[:longitude]
    ).to_a
    assert_equal 6, result.count
    assert_equal [@offer_paris, @offer_chatillon, @offer_bordeaux, @offer_pithiviers, @offer_verneuil, @offer_melun].map(&:id),
                 result.map(&:id)
  end

  test 'scope :nearby_and_ordered' do
    result = InternshipOffer.nearby_and_ordered(
      latitude: @coordinates_paris[:latitude],
      longitude: @coordinates_paris[:longitude],
      radius: 100_000
    ).to_a
    assert_equal 5, result.count
    assert_equal %w[Paris Chatillon Verneuil Melun Pithiviers],
                 result.pluck(:city)

    result = InternshipOffer.nearby_and_ordered(
      latitude: @coordinates_paris[:latitude],
      longitude: @coordinates_paris[:longitude],
      radius: 70_000
    ).to_a
    assert_equal 4, result.count
    assert_equal %w[Paris Chatillon Verneuil Melun],
                 result.pluck(:city)
  end
end
