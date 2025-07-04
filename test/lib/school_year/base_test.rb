# frozen_string_literal: true

require 'test_helper'
module SchoolYear
  # Example implementation for SchoolYear::Current#last_friday_before:
  #
  # def last_friday_before(date)
  #   days_since_friday = (date.wday - 5) % 7
  #   date - days_since_friday
  # end
  class BaseTest < ActiveSupport::TestCase
    test 'last_friday_before' do
      date = Date.new(2023, 3, 31) # friday
      current = SchoolYear::Current.new
      assert_equal date, current.last_friday_before(date)
      assert_equal date, current.last_friday_before(date + 1.day)
      assert_equal date, current.last_friday_before(date + 2.days)
      assert_equal date, current.last_friday_before(date + 3.days)
      assert_equal date, current.last_friday_before(date + 4.days)
      assert_equal date, current.last_friday_before(date + 5.days)

      assert_equal date - 7.days, current.last_friday_before(date - 1.day)
      assert_equal date - 7.days, current.last_friday_before(date - 2.days)
      assert_equal date - 7.days, current.last_friday_before(date - 3.days)
      assert_equal date - 7.days, current.last_friday_before(date - 4.days)
      assert_equal date - 7.days, current.last_friday_before(date - 5.days)
    end

    test 'first_monday_after' do
      date = Date.new(2023, 3, 27) # monday
      current = SchoolYear::Current.new
      assert_equal date, current.first_monday_after(date)
      assert_equal date + 7.days, current.first_monday_after(date + 1.day)
      assert_equal date + 7.days, current.first_monday_after(date + 2.days)
      assert_equal date + 7.days, current.first_monday_after(date + 3.days)
      assert_equal date + 7.days, current.first_monday_after(date + 4.days)
      assert_equal date + 7.days, current.first_monday_after(date + 5.days)

      assert_equal date, current.first_monday_after(date - 1.day)
      assert_equal date, current.first_monday_after(date - 2.days)
      assert_equal date, current.first_monday_after(date - 3.days)
      assert_equal date, current.first_monday_after(date - 4.days)
      assert_equal date, current.first_monday_after(date - 5.days)
    end
  end
end
