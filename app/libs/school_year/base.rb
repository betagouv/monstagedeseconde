# frozen_string_literal: true

module SchoolYear
  class Base
    YEAR_START          = 2019
    MONTH_OF_YEAR_SHIFT = 7
    DAY_OF_YEAR_SHIFT   = 1
    SEPTEMBER = 9
    FIRST = 1

    MONTH_LIST = %w[
      Janvier Février Mars Avril Mai Juin Juillet Aout Septembre Novembre Décembre
    ].rotate(8).freeze

    def strict_beginning_of_period
      case current_month
      when january_to_june
        Date.new(current_year - 1, 9, 1)
      when june_to_december
        Date.new(current_year, 9, 1)
      end
    end

    def january_to_june
      1...MONTH_OF_YEAR_SHIFT
    end

    def june_to_august
      6..8
    end

    def september_to_december
      9..12
    end

    # def between_june_to_august?
    #   june_to_august.member?(current_month)
    # end

    def range
      beginning_of_period..next_year.beginning_of_period
    end

    def next_year
      SchoolYear::Floating.new_by_year(year: end_of_period.year)
    end

    def june_to_december
      6..12
    end

    attr_reader :date

    protected

    def current_year
      date.year
    end

    def current_month
      date.month
    end

    def first_week_of_july?
      last_day_of_may = Date.new(current_year, MONTH_OF_YEAR_SHIFT, DAY_OF_YEAR_SHIFT)
      date.between?(last_day_of_may.beginning_of_week, last_day_of_may.end_of_week)
    end
  end
end
