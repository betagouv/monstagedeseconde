# frozen_string_literal: true

require 'test_helper'

class MultiCoordinatorTest < ActiveSupport::TestCase
  test 'factory builds a valid (private) coordinator' do
    coordinator = build(:multi_coordinator)
    assert coordinator.valid?, coordinator.errors.full_messages.join(', ')
    refute coordinator.is_public
    assert_nil coordinator.group_id
  end

  test 'public coordinator requires a group (ministère)' do
    coordinator = build(:multi_coordinator, is_public: true, group: nil)
    refute coordinator.valid?
    assert_includes coordinator.errors[:group_id], 'Un ministère est requis pour une offre publique'
  end

  test 'public coordinator with group is valid' do
    group = create(:group, is_public: true)
    coordinator = build(:multi_coordinator, is_public: true, group: group)
    assert coordinator.valid?, coordinator.errors.full_messages.join(', ')
  end

  test 'private coordinator must not have a group' do
    group = create(:group, is_public: true)
    coordinator = build(:multi_coordinator, is_public: false, group: group)
    refute coordinator.valid?
    assert_includes coordinator.errors[:group_id], "Il n'y a pas de ministère à associer à une structure privée"
  end

  test 'private coordinator cannot have sector Fonction publique' do
    fonction_publique = Sector.find_or_create_by!(name: 'Fonction publique')
    coordinator = build(:multi_coordinator, is_public: false, group: nil, sector: fonction_publique)
    refute coordinator.valid?
    assert_includes coordinator.errors[:sector_id], "Le secteur 'Fonction publique' n'est pas autorisé pour une offre privée"
  end

  test 'public coordinator can have any sector including Fonction publique' do
    group = create(:group, is_public: true)
    fonction_publique = Sector.find_or_create_by!(name: 'Fonction publique')
    coordinator = build(:multi_coordinator, is_public: true, group: group, sector: fonction_publique)
    assert coordinator.valid?, coordinator.errors.full_messages.join(', ')
  end
end
