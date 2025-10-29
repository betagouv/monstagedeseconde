require 'test_helper'

class EntrepriseTest < ActiveSupport::TestCase
  test 'factory build' do
    entreprise = build(:entreprise)
    assert entreprise.valid?
    assert_equal Coordinates.paris[:latitude], entreprise.entreprise_coordinates.latitude
    assert_equal Coordinates.paris[:longitude], entreprise.entreprise_coordinates.longitude
    assert entreprise.is_public
    refute_nil entreprise.group_id
  end

  test 'factory private entreprise build' do
    entreprise = build(:entreprise, :private)
    assert entreprise.valid?
    refute entreprise.is_public
    assert_nil entreprise.group_id
  end

  test 'factory create' do
    entreprise = create(:entreprise)
    assert entreprise.valid?
    assert entreprise.persisted?
    refute_nil entreprise.id
  end

  test '#entreprise_coordinates' do
    entreprise = build(:entreprise)

    entreprise.entreprise_coordinates = { latitude: 48.8566, longitude: 2.3522 }
    assert_equal 2.3522, entreprise.entreprise_coordinates.longitude
    assert_equal 48.8566, entreprise.entreprise_coordinates.latitude
    assert entreprise.contact_phone.gsub(' ', '').match?(/0\d{9}/)
  end

  test 'entreprise_full_address partially filled form fails gracefully' do
    entreprise = build(:entreprise, entreprise_full_address: '')
    refute entreprise.valid?
    assert_equal "Adresse de l'entreprise est trop court (au moins 8 caractères)",
                 entreprise.errors.full_messages.first
  end
end
