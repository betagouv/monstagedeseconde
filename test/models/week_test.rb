# frozen_string_literal: true

require 'test_helper'

class WeekTest < ActiveSupport::TestCase
  test '#consecutive_to?' do
    week_before, week = Week.order(year: :asc, number: :asc).first(2)
    assert week.consecutive_to?(week_before)
    refute week_before.consecutive_to? week
  end

  test 'scope in_the_future' do
    travel_to(Date.new(2025, 1, 1)) do
      assert Week.in_the_future.count > 52
      assert_equal 2027, Week.in_the_future.map(&:year).sort.last
      assert_equal 52, Week.in_the_future.sort_by(&:number).sort.last.number
      assert_equal 1, Week.in_the_future.sort_by(&:number).sort.last(52).first.number
      ordered_weeks = Week.from_now.order(:year, :number)
      assert_equal 1, ordered_weeks.first.number
      assert_equal 2025, ordered_weeks.first.year
    end
  end

  test 'scope from_now' do
    travel_to(Date.new(2024, 1, 1)) do
      assert Week.from_now.count > 52
      assert_equal 2027, Week.from_now.map(&:year).sort.last
      assert_equal 52, Week.from_now.sort_by(&:number).sort.last.number
      assert_equal 1, Week.from_now.sort_by(&:number).sort.last(52).first.number
    end
  end

  test 'scope from_now at the end of the year' do
    travel_to(Date.new(2026, 12, 31)) do
      # https://fr.wikipedia.org/wiki/Semaine_53, 2020 is a year with 53 weeks
      assert Week.from_now.count > 52
      ordered_weeks = Week.from_now.order(:year, :number)
      assert_equal 53, ordered_weeks.first.number
      assert_equal 2026, ordered_weeks.first.year
    end
  end

  test '.ahead_of_school_year_start?' do
    travel_to(Date.new(2024, 1, 7)) do
      refute Week.current.ahead_of_school_year_start?
    end
    travel_to(Date.new(2024, 5, 26)) do # sunday
      refute Week.current.ahead_of_school_year_start?
    end
    travel_to(Date.new(2024, 5, 31)) do # friday
      assert Week.current.ahead_of_school_year_start?
    end
    travel_to(Date.new(2024, 6, 1)) do # saturday
      assert Week.current.ahead_of_school_year_start?
    end
    travel_to(Date.new(2024, 6, 2)) do # sunday
      assert Week.current.ahead_of_school_year_start?
    end
    travel_to(Date.new(2024, 6, 3)) do # monday
      assert Week.current.ahead_of_school_year_start?
    end
    travel_to(Date.new(2024, 6, 4)) do # tuesday
      assert Week.current.ahead_of_school_year_start?
    end
    travel_to(Date.new(2024, 9, 1)) do # sunday
      assert Week.current.ahead_of_school_year_start?
    end
    travel_to(Date.new(2024, 9, 2)) do # monday
      refute Week.current.ahead_of_school_year_start?
    end
    travel_to(Date.new(2024, 9, 10)) do # tuesday
      refute Week.current.ahead_of_school_year_start?
    end
  end

  test '#beginning_of_week' do
    skip 'leak suspicion'
    travel_to(Date.new(2024, 9, 2)) do
      weeks = Week.selectable_on_school_year
      assert_equal '2 sept.', weeks.first.beginning_of_week(format: :human_dd_mm)
    end
  end
end
