require "test_helper"

class MultiCorporationTest < ActiveSupport::TestCase

  test 'factory is valid' do
    multi_corporation = build(:multi_corporation)
    assert multi_corporation.valid?
  end
end