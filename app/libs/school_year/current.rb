# frozen_string_literal: true

module SchoolYear
  # period from beginning of school year until end
  class Current < Base
    def beginning_of_period
      september_first = Date.new(current_year, SEPTEMBER, FIRST)
      previous_september_first = Date.new(current_year - 1, SEPTEMBER, FIRST)

      case current_month
      when january_to_june
        return september_first if first_week_of_july?

        previous_september_first
      when june_to_december then september_first
      end
    end

    def end_of_period
      year_end_date = Date.new(current_year, MONTH_OF_YEAR_SHIFT, DAY_OF_YEAR_SHIFT)
      next_year_end_date = Date.new(current_year + 1, MONTH_OF_YEAR_SHIFT, DAY_OF_YEAR_SHIFT)
      case current_month
      when january_to_june
        return next_year_end_date if first_week_of_july?

        year_end_date
      when june_to_december then next_year_end_date
      end
    end

    def first_week_internship_monday
      first_week_june = Date.new(year_in_june, 6, 1)
                            .end_of_week
      offset = first_week_june.mday >= 7 ? 8 : 15
      first_week_june.days_since(offset.days)
    end

    def first_week_internship_friday = first_week_internship_monday.days_since(4.days)
    def second_week_internship_monday = first_week_internship_monday.days_since(7.days)
    def second_week_internship_friday = second_week_internship_monday.days_since(4.days)
    def self.year_in_june = new.year_in_june
    def year_in_june = end_of_period.year

    private

    def initialize
      @date = Date.today
    end
  end
end
