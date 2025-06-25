# frozen_string_literal: true

module SchoolYear
  # period from now until end of school year
  class Floating < Base
    def updated_beginning_of_period
      floating_now = Date.new(current_year, Date.today.month, Date.today.day)
      [floating_now, deposit_end_of_period].sort.last
    end

    # year is to be understood the following way:
    # Speaking of school_year 2024/2025, the year is 2025.
    def self.new_by_year(year:)
      new(date: SchoolYear::Floating.shift_day(year: year - 1) + 1.day)
    end

    def shift_day(year:)
      Date.new(year, MONTH_OF_YEAR_SHIFT, DAY_OF_YEAR_SHIFT)
    end

    def self.shift_day(year:)
      Date.new(year, MONTH_OF_YEAR_SHIFT, DAY_OF_YEAR_SHIFT)
    end

    attr_reader :date

    private

    def initialize(date:)
      @date = date
    end
  end
end
