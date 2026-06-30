require "test_helper"

class MultiCorporationTest < ActiveSupport::TestCase

  test 'factory is valid' do
    multi_corporation = build(:multi_corporation)
    assert multi_corporation.valid?
  end

  test 'has many corporations' do
    multi_corporation = create(:multi_corporation)
    assert_equal 5, multi_corporation.corporations.count
    employer_names = multi_corporation.corporations.pluck(:corporation_name)
    expected_names = [
      'Darty lux',
      'Radio Electroménager',
      'Brain Dry Pump',
      'Leaders Connect',
      'Auto Plus Services'
    ]
    assert_equal expected_names.sort, employer_names.sort
  end

  test 'MAX_CORPORATIONS is 2' do
    assert_equal 2, MultiCorporation::MAX_CORPORATIONS
  end

  test '#full? is true only once 2 corporations exist' do
    multi_corporation = create(:multi_corporation)
    multi_corporation.corporations.destroy_all
    refute multi_corporation.reload.full?

    create(:corporation, multi_corporation:, period: 1)
    refute multi_corporation.reload.full?

    create(:corporation, multi_corporation:, period: 2)
    assert multi_corporation.reload.full?
  end

  test '#next_available_period returns 1 then 2 then nil' do
    multi_corporation = create(:multi_corporation)
    multi_corporation.corporations.destroy_all
    assert_equal 1, multi_corporation.reload.next_available_period

    create(:corporation, multi_corporation:, period: 1)
    assert_equal 2, multi_corporation.reload.next_available_period

    create(:corporation, multi_corporation:, period: 2)
    assert_nil multi_corporation.reload.next_available_period
  end
end