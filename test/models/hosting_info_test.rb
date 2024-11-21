require 'test_helper'

class HostingInfoTest < ActiveSupport::TestCase
  test 'factory is valid' do
    assert build(:hosting_info).valid?
  end

  test '#current_period_labels' do
    travel_to Date.new(2025, 1, 1) do
      assert_equal '2 semaines (du 16 au 27 juin 2025)',
                   HostingInfo.current_period_labels.first
    end
    travel_to Date.new(2024, 1, 1) do
      assert_equal '1 semaine (du 17 au 21 juin 2024)',
                   HostingInfo.current_period_labels.second
    end
  end

  test '.current_period_collection' do
    assert_equal [
      ['2 semaines (du 16 au 27 juin 2025)', 0],
      ['1 semaine (du 16 au 20 juin 2025)', 1],
      ['1 semaine (du 23 au 27 juin 2025)', 2]
    ], HostingInfo.current_period_collection
  end
end
