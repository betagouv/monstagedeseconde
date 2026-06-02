# frozen_string_literal: true

require 'test_helper'

class NafSectorMappingTest < ActiveSupport::TestCase
  test 'valid with all attributes' do
    mapping = build(:naf_sector_mapping)
    assert mapping.valid?
  end

  test 'invalid without code_naf' do
    mapping = build(:naf_sector_mapping, code_naf: nil)
    refute mapping.valid?
    assert mapping.errors[:code_naf].any?
  end

  test 'invalid without sector' do
    mapping = build(:naf_sector_mapping, sector: nil)
    refute mapping.valid?
  end

  test 'invalid without date_start' do
    mapping = build(:naf_sector_mapping, date_start: nil)
    refute mapping.valid?
  end

  test 'invalid without date_end' do
    mapping = build(:naf_sector_mapping, date_end: nil)
    refute mapping.valid?
  end

  test 'invalid when date_end is before date_start' do
    mapping = build(:naf_sector_mapping, date_start: Date.new(2025, 1, 1), date_end: Date.new(2024, 1, 1))
    refute mapping.valid?
    assert_includes mapping.errors[:date_end], 'doit être postérieure à la date de début'
  end

  test '.active_at returns mappings active at a given date' do
    active = create(:naf_sector_mapping, date_start: Date.new(2024, 1, 1), date_end: Date.new(2026, 12, 31))
    expired = create(:naf_sector_mapping, code_naf: '10.01Z', date_start: Date.new(2020, 1, 1), date_end: Date.new(2023, 12, 31))

    results = NafSectorMapping.active_at(Date.new(2025, 6, 1))
    assert_includes results, active
    refute_includes results, expired
  end

  test '.find_sector_by_code_naf returns sector for exact code_naf match' do
    sector = create(:sector, name: 'Informatique et réseaux')
    create(:naf_sector_mapping, code_naf: '62.01Z', sector: sector)

    found = NafSectorMapping.find_sector_by_code_naf('62.01Z')
    assert_equal sector, found
  end

  test '.find_sector_by_code_naf falls back to prefix match' do
    sector = create(:sector, name: 'Informatique et réseaux')
    create(:naf_sector_mapping, code_naf: '62', sector: sector)

    found = NafSectorMapping.find_sector_by_code_naf('62.09Z')
    assert_equal sector, found
  end

  test '.find_sector_by_code_naf prefers exact match over prefix' do
    sector_exact = create(:sector, name: 'Programmation informatique')
    sector_prefix = create(:sector, name: 'Informatique et réseaux')
    create(:naf_sector_mapping, code_naf: '62.01Z', sector: sector_exact)
    create(:naf_sector_mapping, code_naf: '62', sector: sector_prefix)

    found = NafSectorMapping.find_sector_by_code_naf('62.01Z')
    assert_equal sector_exact, found
  end

  test '.find_sector_by_code_naf returns nil for blank code' do
    assert_nil NafSectorMapping.find_sector_by_code_naf(nil)
    assert_nil NafSectorMapping.find_sector_by_code_naf('')
  end

  test '.find_sector_by_code_naf ignores expired mappings' do
    sector = create(:sector, name: 'Informatique et réseaux')
    create(:naf_sector_mapping, code_naf: '62.01Z', sector: sector,
           date_start: Date.new(2020, 1, 1), date_end: Date.new(2023, 12, 31))

    found = NafSectorMapping.find_sector_by_code_naf('62.01Z')
    assert_nil found
  end
end
