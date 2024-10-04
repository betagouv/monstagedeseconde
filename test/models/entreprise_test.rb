require 'test_helper'

class EntrepriseTest < ActiveSupport::TestCase
  test 'factory' do
    entreprise = build(:entreprise)
    assert entreprise.valid?
    assert entreprise.save
  end

  test '#entreprise_coordinates' do
    entreprise = build(:entreprise)

    entreprise.entreprise_coordinates = { latitude: 48.8566, longitude: 2.3522 }
    assert_equal 2.3522, entreprise.entreprise_coordinates.longitude
    assert_equal 48.8566, entreprise.entreprise_coordinates.latitude
  end
end
