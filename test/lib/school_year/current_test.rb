# frozen_string_literal: true

require 'test_helper'
module SchoolYear
  class CurrentTest < ActiveSupport::TestCase
    test '.offers_beginning_of_period / deposit_end_of_period from january to may' do
      travel_to(Date.new(2019, 1, 1)) do
        school_year = Current.new
        assert_equal Date.new(2018, 9, 3), school_year.offers_beginning_of_period # first monday after september 1st
        assert_equal Date.new(2018, 7, 1), school_year.deposit_beginning_of_period
        assert_equal Date.new(2019, 6, 28), school_year.offers_end_of_period
        assert_equal Date.new(2019, 7, 1), school_year.deposit_end_of_period
      end
    end

    test '.offers_beginning_of_period / deposit_end_of_period from june to september' do
      travel_to(Date.new(2019, 7, 1)) do
        school_year = Current.new
        assert_equal Date.new(2019, 9, 2), school_year.offers_beginning_of_period # first monday after september 1st
        assert_equal Date.new(2019, 7, 1), school_year.deposit_beginning_of_period
        assert_equal Date.new(2020, 6, 26), school_year.offers_end_of_period
        assert_equal Date.new(2020, 7, 1), school_year.deposit_end_of_period
      end
    end

    test '.offers_beginning_of_period / deposit_end_of_period overlap year shift' do
      travel_to(Date.new(2019, 7, 5)) do
        school_year = Current.new
        assert_equal Date.new(2019, 9, 2), school_year.offers_beginning_of_period # first monday after september 1st
        assert_equal Date.new(2019, 7, 1), school_year.deposit_beginning_of_period
        assert_equal Date.new(2020, 6, 26), school_year.offers_end_of_period
        assert_equal Date.new(2020, 7, 1), school_year.deposit_end_of_period
      end
    end

    test 'offers_beginning_of_period / deposit_end_of_period from september to december' do
      travel_to(Date.new(2019, 9, 1)) do
        school_year = Current.new
        assert_equal Date.new(2019, 9, 2), school_year.offers_beginning_of_period # first monday after september 1st
        assert_equal Date.new(2019, 7, 1), school_year.deposit_beginning_of_period
        assert_equal Date.new(2020, 6, 26), school_year.offers_end_of_period # last friday before july 1st
        assert_equal Date.new(2020, 7, 1), school_year.deposit_end_of_period
      end
    end

    test '.from_now_to_end_of_current_year_limits' do
      travel_to(Date.new(2025, 1, 1)) do
        current = Current.new
        assert_equal Date.new(2025, 1, 6), current.from_now_to_end_of_current_year_limits[:from]
        assert_equal Date.new(2025, 5, 30), current.from_now_to_end_of_current_year_limits[:to]
      end
    end

    test '.current_year_limits' do
      travel_to(Date.new(2025, 1, 1)) do
        current = Current.new
        assert_equal Date.new(2024, 9, 2), current.current_year_limits[:from]
        assert_equal Date.new(2025, 5, 30), current.current_year_limits[:to]
      end
    end
    test '.from_now_to_end_of_current_year_limits during summer holidays' do
      travel_to(Date.new(2025, 8, 1)) do
        current = Current.new
        assert_equal Date.new(2025, 9, 1), current.from_now_to_end_of_current_year_limits[:from]
        assert_equal Date.new(2026, 5, 29), current.from_now_to_end_of_current_year_limits[:to]
      end
    end

    test '.current_year_limits during summer holidays' do
      travel_to(Date.new(2025, 8, 1)) do
        current = Current.new
        assert_equal Date.new(2025, 9, 1), current.current_year_limits[:from]
        assert_equal Date.new(2026, 5, 29), current.current_year_limits[:to]
      end
    end

    test '.from_now_to_end_of_current_year_deposit_limits' do
      travel_to(Date.new(2025, 1, 1)) do
        current = Current.new
        assert_equal Date.new(2025, 1, 6), current.from_now_to_end_of_current_year_deposit_limits[:from]
        assert_equal Date.new(2025, 6, 27), current.from_now_to_end_of_current_year_deposit_limits[:to]
      end
    end
    test '.current_year_deposit_limits' do
      travel_to(Date.new(2025, 1, 1)) do
        current = Current.new
        assert_equal Date.new(2024, 7, 1), current.current_year_deposit_limits[:from]
        assert_equal Date.new(2025, 6, 27), current.current_year_deposit_limits[:to]
      end
    end
  end
end
