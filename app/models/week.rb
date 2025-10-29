# frozen_string_literal: true

# Calendar weeks
class Week < ApplicationRecord
  include FormatableWeek
  include WeekHelpers
  WORKING_WEEK_DURATION = 5
  has_many :internship_applications, dependent: :destroy,
                                     foreign_key: :week_id

  # def self.end_of_year_week?(date)
  #   date.cweek == 53 && date.month == 12
  # end

  # not used anymore
  scope :of_past_school_years, lambda {
    strictly_after_week(week: Week.current_year_start_week)
  }

  # TODO: update this name to 'of_current_school_year'
  scope :selectable_on_school_year, lambda {
    from_date_to_date(**current_year_limits)
  }

  scope :selectable_for_school_year, lambda { |school_year:|
    weeks_of_school_year(school_year: school_year.offers_beginning_of_period.year)
  }

  scope :selectable_from_now_until_end_of_school_year, lambda {
    from_date_to_date(**from_now_to_end_of_current_year_limits)
  }

  scope :troisieme_weeks, lambda {
    from_date_to_date(**current_troisieme_year_limits)
  }

  scope :troisieme_selectable_weeks, lambda {
    from_date_to_date(**from_now_to_end_of_current_troisieme_year_limits)
  }

  scope :deposit_troisieme_weeks, lambda {
    from_date_to_date(**current_year_deposit_limits)
  }

  scope :both_school_tracks_weeks, lambda {
    where(id: [troisieme_weeks, seconde_weeks].map(&:ids).flatten.uniq)
  }

  scope :both_school_track_selectable_weeks, lambda {
    both_school_tracks_weeks.in_the_future
  }

  scope :selectable_from_now_until_next_school_year, lambda {
    from_now_to_end_of_current_year_limits => { from:, to: }
    from_date_to_date(from: from, to: to + 1.year)
  }

  scope :selectable_on_next_school_year, lambda {
    current_year_limits => { from:, to: }
    from_date_to_date(from: from + 1.year, to: to + 1.year)
  }

  scope :of_previous_school_year, lambda {
    current_year_limits => { from:, to: }
    from_date_to_date(from: from - 1.year, to: to - 1.year)
  }

  # scope :selectable_on_specific_school_year, lambda { |school_year:|
  #   weeks_of_school_year(school_year: school_year.offers_beginning_of_period.year)
  # }

  scope :selectable_on_school_year_when_editing, lambda {
    if Week.current.ahead_of_school_year_start?
      selectable_from_now_until_end_of_school_year
    else
      selectable_from_now_until_end_of_school_year.or(selectable_on_next_school_year)
    end
  }

  scope :weeks_of_school_year, lambda { |school_year:|
    first_week_of_september = Date.new(school_year, 9, 1).cweek
    first_day_of_july_week ||= Date.new(school_year + 1, SchoolYear::Base::MONTH_OF_YEAR_SHIFT, SchoolYear::Base::MONTH_OF_YEAR_SHIFT).cweek

    where('number >= ?', first_week_of_september).where(year: school_year)
                                                 .or(where('number <= ?', first_day_of_july_week).where(year: school_year + 1))
  }

  def to_s_in_api
    "#{year}-W#{number.to_s.rjust(2, '0')}"
  end

  def self.current_year_start_week
    current_school_year.offers_beginning_of_period_week
  end

  def self.seconde_weeks
    SchoolTrack::Seconde.both_weeks
  end

  def self.seconde_selectable_weeks
    seconde_weeks.in_the_future
  end

  WEEK_DATE_FORMAT = '%d/%m/%Y'

  def ahead_of_school_year_start?
    return false if number > 50 && number < 2 # week 53 justifies this

    just_after_troisieme_end_of_period = first_monday_after(Date.new(year, SchoolYear::Base::MONTH_OF_3EME_YEAR_END,
                                                                     SchoolYear::Base::FIRST)) - 1.week
    school_year_start = last_friday_before(Date.new(year, SchoolYear::Base::SEPTEMBER,
                                                    SchoolYear::Base::FIRST)) + 3.days

    week_date.beginning_of_week >= just_after_troisieme_end_of_period &&
      week_date.end_of_week < school_year_start
  end

  def in_the_past?
    week_date.end_of_week < Date.current
  end

  rails_admin do
    export do
      field :number
      field :year
    end
  end
end
