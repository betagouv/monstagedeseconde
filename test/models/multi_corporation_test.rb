require "test_helper"

class MultiCorporationTest < ActiveSupport::TestCase

  test 'factory is valid' do
    multi_corporation = build(:multi_corporation)
    assert multi_corporation.valid?
  end

  test 'has many corporations' do
    multi_corporation = create(:multi_corporation)
    assert_equal 5, multi_corporation.corporations.count
    employer_names = multi_corporation.corporations.pluck(:employer_name)
    expected_names = [
      'Darty lux',
      'Radio Electroménager',
      'Brain Dry Pump',
      'Leaders Connect',
      'Auto Plus Services'
    ]
    assert_equal expected_names.sort, employer_names.sort
  end
end