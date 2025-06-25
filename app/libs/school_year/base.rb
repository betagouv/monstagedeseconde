# frozen_string_literal: true

module SchoolYear
  class Base
    YEAR_START          = 2019
    MONTH_OF_YEAR_SHIFT = 7
    DAY_OF_YEAR_SHIFT   = 1
    SEPTEMBER           = 9
    FIRST               = 1

    MONTH_LIST = %w[
      Janvier Février Mars Avril Mai Juin Juillet Aout Septembre Novembre Décembre
    ].rotate(8).freeze

    def january_to_end_of_period
      1...MONTH_OF_YEAR_SHIFT
    end

    def end_of_period_to_december
      MONTH_OF_YEAR_SHIFT..12
    end

    # def range
    #   beginning_of_period..next_year.offers_beginning_of_period
    # end

    def next_year
      SchoolYear::Floating.new_by_year(year: current_year + 1)
    end

    def offers_beginning_of_period
      case current_month
      when january_to_end_of_period
        Date.new(current_year - 1, SEPTEMBER, FIRST)
      when end_of_period_to_december
        Date.new(current_year, SEPTEMBER, FIRST)
      end
    end

    def deposit_beginning_of_period
      case current_month
      when january_to_end_of_period
        Date.new(current_year - 1, MONTH_OF_YEAR_SHIFT, DAY_OF_YEAR_SHIFT)
      when end_of_period_to_december
        Date.new(current_year, MONTH_OF_YEAR_SHIFT, DAY_OF_YEAR_SHIFT)
      end
    end

    def offers_end_of_period
      case current_month
      when january_to_end_of_period
        Date.new(current_year, MONTH_OF_YEAR_SHIFT, DAY_OF_YEAR_SHIFT)
      when end_of_period_to_december
        Date.new(current_year + 1, MONTH_OF_YEAR_SHIFT, DAY_OF_YEAR_SHIFT)
      end
    end

    def deposit_end_of_period
      offers_end_of_period
    end

    def offers_beginning_of_period_week
      Week.fetch_from(date: offers_beginning_of_period)
    end

    def deposit_beginning_of_period_week
      Week.fetch_from(date: deposit_beginning_of_period)
    end

    def offers_end_of_period_week
      Week.fetch_from(date: offers_end_of_period)
    end

    def deposit_end_of_period_week
      Week.fetch_from(date: deposit_end_of_period)
    end

    def last_friday_before(date)
      # if date is a Friday, return it
      return date if date.friday?

      wday = date.wday
      date.days_since(-2 - wday)
    end

    def first_monday_after(date)
      # if date is a Monday, return it
      return date if date.monday?

      wday = date.wday
      date.days_since(8 - wday)
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
