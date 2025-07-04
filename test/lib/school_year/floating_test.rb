# frozen_string_literal: true

require 'test_helper'
module SchoolYear
  class FloatingTest < ActiveSupport::TestCase
    test '.offers_beginning_of_period / deposit_end_of_period from january to may' do
      travel_to(Date.new(2020, 1, 1)) do
        school_year = Floating.new(date: Date.today)
        assert_equal Date.new(2019, 9, 2), school_year.offers_beginning_of_period # first monday after september 1st
        assert_equal Date.new(2019, 7, 1), school_year.deposit_beginning_of_period
        assert_equal Date.new(2020, 6, 26), school_year.offers_end_of_period # last friday before july 1st
        assert_equal Date.new(2020, 7, 1), school_year.deposit_end_of_period
      end
    end

    test '.offers_beginning_of_period / deposit_end_of_period overlap year shift on 2020' do
      school_year = Floating.new(date: Date.new(2020, 6, 28))
      assert_equal Date.new(2019, 9, 2), school_year.offers_beginning_of_period
      assert_equal Date.new(2019, 7, 1), school_year.deposit_beginning_of_period
      assert_equal Date.new(2020, 6, 26), school_year.offers_end_of_period
      assert_equal Date.new(2020, 7, 1), school_year.deposit_end_of_period
    end

    test '.offers_beginning_of_period / deposit_end_of_period from june to september' do
      school_year = Floating.new(date: Date.new(2019, 7, 2))
      assert_equal Date.new(2019, 9, 2), school_year.offers_beginning_of_period
      assert_equal Date.new(2019, 7, 1), school_year.deposit_beginning_of_period
      assert_equal Date.new(2020, 6, 26), school_year.offers_end_of_period
      assert_equal Date.new(2020, 7, 1), school_year.deposit_end_of_period
    end

    test '.offers_beginning_of_period / deposit_end_of_period from september to december' do
      school_year = Floating.new(date: Date.new(2019, 9, 1))
      assert_equal Date.new(2019, 9, 2), school_year.offers_beginning_of_period
      assert_equal Date.new(2019, 7, 1), school_year.deposit_beginning_of_period
      assert_equal Date.new(2020, 6, 26), school_year.offers_end_of_period
      assert_equal Date.new(2020, 7, 1), school_year.deposit_end_of_period
    end

    test '.offers_beginning_of_period_week' do
      school_year = Floating.new(date: Date.new(2019, 9, 1))
      assert_equal Week.fetch_from(date: Date.new(2019, 9, 2)), school_year.offers_beginning_of_period_week
    end

    test '.deposit_beginning_of_period_week' do
      school_year = Floating.new(date: Date.new(2019, 9, 1))
      assert_equal Week.fetch_from(date: Date.new(2019, 7, 1)), school_year.deposit_beginning_of_period_week
    end
  end
end
