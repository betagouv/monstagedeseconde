# frozen_string_literal: true

require 'test_helper'
module SchoolYear
  class FloatingTest < ActiveSupport::TestCase
    test '.beginning_of_period / end_of_period from january to may' do
      travel_to(Date.new(2019, 1, 1)) do
        school_year = Floating.new(date: Date.today)
        assert_equal Date.today, school_year.updated_beginning_of_period
        assert_equal Date.new(2019, 8, 1), school_year.end_of_period
      end
    end

    test '.beginning_of_period / end_of_period from june to september' do
      travel_to(Date.new(2019, 8, 2)) do
        school_year = Floating.new(date: Date.today)
        assert_equal Date.new(2019, 9, 1), school_year.beginning_of_period
        assert_equal Date.new(2020, 8, 1), school_year.end_of_period
      end
    end

    test '.beginning_of_period / end_of_period overlap year shift on 2020' do
      travel_to(Date.new(2019, 8, 1)) do
        school_year = Floating.new(date: Date.today)
        assert_equal Date.new(2019, 9, 1), school_year.beginning_of_period
        assert_equal Date.new(2020, 8, 1), school_year.end_of_period
      end
    end

    test '.beginning_of_period / end_of_period overlap year shift on 2021' do
      travel_to(Date.new(2021, 8, 1)) do
        school_year = Floating.new(date: Date.today)
        assert_equal Date.new(2021, 9, 1), school_year.beginning_of_period
        assert_equal Date.new(2022, 8, 1), school_year.end_of_period
      end
    end

    test '.beginning_of_period / end_of_period from september to december' do
      travel_to(Date.new(2019, 9, 1)) do
        school_year = Floating.new(date: Date.today)
        assert_equal Date.new(2019, 9, 1), school_year.beginning_of_period
        assert_equal Date.new(2020, 8, 1), school_year.end_of_period
      end
    end
  end
end
