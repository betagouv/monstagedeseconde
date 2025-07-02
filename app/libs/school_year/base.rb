# frozen_string_literal: true

module SchoolYear
  class Base
    YEAR_START             = 2019
    MONTH_OF_YEAR_SHIFT    = 7
    MONTH_OF_3EME_YEAR_END = 6
    SEPTEMBER              = 9
    FIRST                  = 1

    MONTH_LIST = %w[
      Janvier Février Mars Avril Mai Juin Juillet Aout Septembre Novembre Décembre
    ].rotate(8).freeze

    def january_to_end_of_period
      1...MONTH_OF_YEAR_SHIFT
    end

    def end_of_period_to_december
      MONTH_OF_YEAR_SHIFT..12
    end

    def year_in_june = deposit_end_of_period.year
    def self.year_in_june = new.year_in_june

    # ------------- offers visibility limits -------------
    def current_year_limits
      current_troisieme_year_limits
      # from = first_monday_after(offers_beginning_of_period)
      # to = last_friday_before(offers_end_of_period)

      # { from: from, to: to }
    end

    def from_now_to_end_of_current_year_limits
      from_now_to_end_of_current_troisieme_year_limits
      # # minimum date is the maximum between first monday after today
      # # and first monday after offers beginning of period
      # from = [first_monday_after(date), first_monday_after(offers_beginning_of_period)].max
      # # maximum date is the last friday before deposit end of period
      # to = last_friday_before(offers_end_of_period)

      # { from: from, to: to }
    end

    def current_troisieme_year_limits
      from = first_monday_after(offers_beginning_of_period)
      to   = last_friday_before(troisieme_end_of_period)

      { from: from, to: to }
    end

    def from_now_to_end_of_current_troisieme_year_limits
      from = [first_monday_after(date), first_monday_after(offers_beginning_of_period)].max
      to   = last_friday_before(troisieme_end_of_period)

      { from: from, to: to }
    end

    # ------------- deposit limits -------------

    def current_year_deposit_limits
      from = first_monday_after(deposit_beginning_of_period)
      to   = last_friday_before(deposit_end_of_period)

      { from: from, to: to }
    end

    def from_now_to_end_of_current_year_deposit_limits
      from = [first_monday_after(date), first_monday_after(deposit_beginning_of_period)].max
      to = last_friday_before(deposit_end_of_period)

      { from: from, to: to }
    end

    def next_year
      SchoolYear::Floating.new_by_year(year: current_year + 1)
    end

    #  beginnings
    def offers_beginning_of_period
      first_monday_after(Date.new(current_year - 1, SEPTEMBER, FIRST))
    end

    def deposit_beginning_of_period
      Date.new(current_year - 1, MONTH_OF_YEAR_SHIFT, FIRST)
    end

    #  ends
    def offers_end_of_period
      last_friday_before(Date.new(current_year, MONTH_OF_YEAR_SHIFT, FIRST))
    end

    def troisieme_end_of_period
      last_friday_before(Date.new(current_year, MONTH_OF_3EME_YEAR_END, FIRST))
    end

    def deposit_end_of_period
      deposit_beginning_of_period + 1.year
    end

    # ---- weeks ----

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

    # ---- helpers ----

    def last_friday_before(date)
      # if date is a Friday, return it
      return date if date.friday?

      days_since_friday = (date.wday - 5) % 7
      date - days_since_friday
    end

    def first_monday_after(date)
      # if date is a Monday, return it
      return date if date.monday?

      # else return the next Monday
      days_until_monday = (1 - date.wday) % 7
      date + days_until_monday
    end

    attr_reader :date

    protected

    def current_month
      date.month
    end

    def current_year
      year = date.year
      case current_month
      when january_to_end_of_period
        year
      when end_of_period_to_december
        year + 1
      end
    end
  end
end
