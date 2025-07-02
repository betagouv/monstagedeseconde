require 'test_helper'
require 'pretty_console'

module SchoolTrack
  class SecondeTest < ActiveSupport::TestCase
    test 'both_weeks are ok' do
      travel_to(Date.new(2023, 6, 30)) do
        assert_equal 2, Seconde.both_weeks.count
        assert_equal Seconde.first_week, Seconde.both_weeks.first
        assert_equal Seconde.second_week, Seconde.both_weeks.last
        assert_equal Seconde.both_weeks, [Seconde.first_week, Seconde.second_week]
        assert_equal Date.new(2023, 6, 19), Seconde.first_week.monday
        assert_equal Date.new(2023, 6, 30), Seconde.second_week.friday
      end
      travel_to(Date.new(2025, 6, 26)) do
        assert_equal 2, Seconde.both_weeks.count
        assert_equal Seconde.first_week, Seconde.both_weeks.first
        assert_equal Seconde.second_week, Seconde.both_weeks.last
        assert_equal Seconde.both_weeks, [Seconde.first_week, Seconde.second_week]
        assert_equal Date.new(2025, 6, 16), Seconde.first_week.monday
        assert_equal Date.new(2025, 6, 27), Seconde.second_week.friday
        assert_equal 338, Seconde.both_weeks.first.id
        assert_equal 339, Seconde.both_weeks.last.id
      end
    end
  end
end
