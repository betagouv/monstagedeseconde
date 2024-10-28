require 'test_helper'

class EntrepriseTest < ActiveSupport::TestCase
  test 'factory build' do
    entreprise = build(:entreprise)
    assert entreprise.valid?
    assert_equal Coordinates.paris[:latitude], entreprise.entreprise_coordinates.latitude
    assert_equal Coordinates.paris[:longitude], entreprise.entreprise_coordinates.longitude
  end

  test 'factory create' do
    entreprise = create(:entreprise)
    refute_nil entreprise.id
  end

  test '#entreprise_coordinates' do
    entreprise = build(:entreprise)

    entreprise.entreprise_coordinates = { latitude: 48.8566, longitude: 2.3522 }
    assert_equal 2.3522, entreprise.entreprise_coordinates.longitude
    assert_equal 48.8566, entreprise.entreprise_coordinates.latitude
  end

  test 'tutor partially filled form fails gracefully' do
    entreprise = build(:entreprise, entreprise_full_address: '')
    refute entreprise.valid?
    assert_equal 'Prénom du tuteur Les informations du tuteur doivent être entièrement renseignées ou totalement vides',
                 entreprise.errors.full_messages.first
  end
end
