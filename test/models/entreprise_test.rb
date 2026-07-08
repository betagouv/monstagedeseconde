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

  test 'private entreprise auto-assigns sector from NAF mapping' do
    sector_info = create(:sector, name: 'Informatique et réseaux')
    create(:naf_sector_mapping, code_naf: '62.01Z', sector: sector_info)
    other_sector = create(:sector, name: 'Autre secteur')

    entreprise = build(:entreprise, :private, sector: other_sector, code_ape: '62.01Z')
    # Reset sector_id_changed? tracking so the before_validation triggers
    entreprise.clear_changes_information

    entreprise.valid?
    assert_equal sector_info.id, entreprise.sector_id
  end

  test 'private entreprise keeps user-chosen sector when no NAF mapping exists' do
    chosen_sector = create(:sector, name: 'Mon secteur')
    entreprise = build(:entreprise, :private, sector: chosen_sector, code_ape: '99.99Z')
    entreprise.clear_changes_information

    entreprise.valid?
    assert_equal chosen_sector.id, entreprise.sector_id
  end

  test 'entreprise_full_address partially filled form fails gracefully' do
    entreprise = build(:entreprise, entreprise_full_address: '')
    refute entreprise.valid?
    assert_equal "Adresse de l'entreprise est trop court (au moins 8 caractères)",
                 entreprise.errors.full_messages.first
  end

  # MGF-1666 : workspace_conditions / workspace_accessibility facultatifs,
  # mais au moins 10 caractères si renseignés.
  test 'workspace fields are optional (blank is valid)' do
    entreprise = build(:entreprise, workspace_conditions: '', workspace_accessibility: '')
    assert entreprise.valid?, entreprise.errors.full_messages.to_sentence
  end

  test 'workspace_conditions shorter than 10 chars is invalid' do
    entreprise = build(:entreprise, workspace_conditions: 'court')
    refute entreprise.valid?
    assert entreprise.errors[:workspace_conditions].present?
  end

  test 'workspace_accessibility shorter than 10 chars is invalid' do
    entreprise = build(:entreprise, workspace_accessibility: 'court')
    refute entreprise.valid?
    assert entreprise.errors[:workspace_accessibility].present?
  end

  test 'workspace fields with at least 10 chars are valid' do
    entreprise = build(:entreprise,
                       workspace_conditions: 'Open space lumineux et calme',
                       workspace_accessibility: 'Ascenseur et rampe disponibles')
    assert entreprise.valid?, entreprise.errors.full_messages.to_sentence
  end
end
