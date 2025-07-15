module WeekHelpers
  extend ActiveSupport::Concern
  #  scope helpers -------------
  included do
    scope :from_date_to_date, lambda { |from:, to:|
      if from.year == to.year
        from_date_for_current_year(from:).to_date_for_current_year(to:)
      else
        from_date_for_current_year(from:).or(to_date_for_current_year(to:))
      end
    }

    # from is a week
    scope :from_date_for_current_year, lambda { |from:|
      where(year: from.year).where('number >= :from_week', from_week: from.cweek)
    }

    # to is a week
    scope :to_date_for_current_year, lambda { |to:|
      where(year: to.year).where('number <= :to_week', to_week: to.cweek)
    }

    scope :strictly_before, lambda { |date:|
      where('year < ?', date.year).or(
        where('year = ?', date.year).where('number < ?', date.cweek)
      )
    }

    scope :strictly_after, lambda { |date:|
      where('year > ?', date.year).or(
        where('year = ?', date.year).where('number > ?', date.cweek)
      )
    }
    scope :strictly_before_week, lambda { |week:|
      where('year < ?', week.year).or(
        where('year = ?', week.year).where('number < ?', week.number)
      )
    }

    scope :strictly_after_week, lambda { |week:|
      if week.nil?
        none
      else
        where('year > ?', week.year).or(
          where('year = ?', week.year).where('number > ?', week.number)
        )
      end
    }

    scope :before, lambda { |date:|
      where('year < ?', date.year).or(
        where('year = ?', date.year).where('number <= ?', date.cweek)
      )
    }

    scope :after, lambda { |date:|
      if Date.current.cweek == 53 && Date.current.month == 1
        where('year >= ?', Date.current.year)
      else
        where('year > ?', date.year).or(
          where('year = ?', date.year).where('number >= ?', date.cweek)
        )
      end
    }
    scope :before_week, lambda { |week:|
      where('year < ?', week.year).or(
        where('year = ?', week.year).where('number < ?', week.number)
      )
    }

    scope :after_week, lambda { |week:|
      if week.nil?
        none
      else
        where('year > ?', week.year).or(
          where('year = ?', week.year).where('number > ?', week.number)
        )
      end
    }

    scope :from_now, lambda {
      current_date = Date.current
      after(date: current_date)
      # # before 31st of December
      # if end_of_year_week?(current_date)
      #   where('number = ?', 53).where('year = ?', current_date.year).or(where('year > ?', current_date.year))

      # elsif current_date.cweek == 53 && current_date.month == 1 #  after 1st of January
      #   where('year >= ?', current_date.year)
      # else
      #   after(date: current_date)
      # end
      # in_the_future
    }

    scope :in_the_future, lambda {
      after(date: Date.current)
    }

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

    alias_method :monday, :week_date

    def friday
      monday + 4.days
    end

    def <(other)
      year < other.year || (year == other.year && number < other.number)
    end

    def consecutive_to?(other_week)
      id.to_i == other_week.id.to_i + 1
    end
  end

  class_methods do
    def fetch_from(date:)
      number = date.cweek
      year = number == 53 ? date.year - 1 : date.year
      find_by(number:, year:)
    end

    def current_school_year
      @current_school_year ||= SchoolYear::Current.new
    end

    # LIMITS
    # -- offers visibility --
    def from_now_to_end_of_current_year_limits
      current_school_year.from_now_to_end_of_current_year_limits
    end

    def current_year_limits
      current_school_year.current_year_limits
    end

    def current_troisieme_year_limits
      current_school_year.current_troisieme_year_limits
    end

    def from_now_to_end_of_current_troisieme_year_limits
      current_school_year.from_now_to_end_of_current_troisieme_year_limits
    end

    # -- end of offers visibility --

    # -- deposit visibility --
    def deposit_beginning_of_period_week
      current_school_year.deposit_beginning_of_period_week
    end

    def deposit_end_of_period_week
      current_school_year.deposit_end_of_period_week
    end

    # -- deposit weeks --
    def current_year_deposit_limits
      current_school_year.current_year_deposit_limits
    end

    def from_now_to_end_of_current_year_deposit_limits
      current_school_year.from_now_to_end_of_current_year_deposit_limits
    end

    def current
      fetch_from(date: Date.today)
    end

    def next
      fetch_from(date: Date.today + 1.week)
    end
  end
end
