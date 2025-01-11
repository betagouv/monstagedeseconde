require 'test_helper'

class InternshipApplicationWeekTest < ActiveSupport::TestCase
  test 'factory' do
    assert build(:internship_application_week).valid?
  end
end
