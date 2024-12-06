require 'test_helper'

class UpdateInternshipOffersAddressesTest < ActiveSupport::TestCase
  Monstage::Application.load_tasks

  test 'update internship offers addresses' do
    internship_offer = create(:weekly_internship_offer_2nde)
    internship_offer.update(street: nil, zipcode: nil, city: nil, coordinates: nil)

    Rake::Task['update_internship_offers:update_addresses'].invoke

    internship_offer.reload
    assert_equal internship_offer.street, internship_offer.internship_occupation.street
    assert_equal internship_offer.zipcode, internship_offer.internship_occupation.zipcode
    assert_equal internship_offer.city, internship_offer.internship_occupation.city
    assert_equal internship_offer.coordinates, internship_offer.internship_occupation.coordinates
  end
end
