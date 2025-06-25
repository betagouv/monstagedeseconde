require 'test_helper'
module Presenters
  class WeekListTest < ActiveSupport::TestCase
    test '#first_joined_weeks' do
      first_weeks_trunck  = Week.where(year: 2019).order(number: :asc).first(3)
      second_weeks_trunck = [Week.where(year: 2020).order(number: :asc).last,
                             Week.find_by(year: 2021, number: 1)]
      weeks = first_weeks_trunck + second_weeks_trunck

      wl_1 = Presenters::WeekList.new(weeks: first_weeks_trunck)
      wl_2 = Presenters::WeekList.new(weeks: second_weeks_trunck)
      wl   = Presenters::WeekList.new(weeks:)

      assert_equal 1, wl_1.split_weeks_in_trunks.count
      assert_equal wl_1.to_s, wl_1.split_weeks_in_trunks.first.to_s

      assert_equal 2, wl.split_weeks_in_trunks.count
      assert_equal wl_1.to_s, wl.split_weeks_in_trunks.first.to_s
      assert_equal wl_2.to_s, wl.split_weeks_in_trunks.second.to_s
    end

    test '#month_split' do
      weeks = Week.where(year: 2019).order(number: :asc).first(10).last(5)
      week_list = Presenters::WeekList.new(weeks:)

      month_split = week_list.month_split

      assert_equal 2, month_split.count
      assert [2, 3] == month_split.keys
      assert_equal 5, month_split.values.flatten.count
    end

    test '#detailed_attributes' do
      weeks = Week.where(year: 2019).order(number: :asc).first(10).last(5)
      week_list = Presenters::WeekList.new(weeks:)

      detailed_attributes = week_list.detailed_attributes

      assert_equal 5, detailed_attributes.count
      assert_equal([6, 7, 8, 9, 10], detailed_attributes.map { |week| week[:id] })
      assert_equal([6, 7, 8, 9, 10], detailed_attributes.map { |week| week[:number] })
      assert_equal([2, 2, 2, 2, 3], detailed_attributes.map { |week| week[:month] })
      assert_equal(%w[Février Février Février Février Mars], detailed_attributes.map do |week|
        week[:monthName]
      end)
      assert_equal([2019, 2019, 2019, 2019, 2019], detailed_attributes.map { |week| week[:year] })
    end
  end
end
