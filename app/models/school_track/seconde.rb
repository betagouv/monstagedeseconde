module SchoolTrack
  class Seconde < Base
    def self.current_period_data
      period_collection(school_year: current_year)
    end

    def self.current_period_labels
      period_labels(school_year: current_year)
    end

    def self.period_labels(school_year:)
      period_collection(school_year:).transform_values do |time_frame|
        prefix = time_frame[:end] - time_frame[:start] > 10 ? ' stage de 2 semaines' : 'stage de 1 semaine'
        "#{prefix} (du #{time_frame[:start]} au #{time_frame[:end]} #{time_frame[:month]} #{time_frame[:year]})"
      end
    end

    def self.first_week(year: current_year)
      Week.fetch_from(date: first_friday(year:))
    end

    def self.second_week(year: current_year)
      Week.fetch_from(date: last_friday(year:))
    end

    def self.both_weeks(year: current_year)
      Week.from_date_to_date(from: first_monday(year:), to: last_friday(year:))
    end

    def self.last_june_friday(year: current_year)
      last_day_of_period = Date.new(year, SWITCH_MONTH, SWITCH_DAY) - 1.day
      wday = last_day_of_period.wday
      offset = wday >= 5 ? wday - 5 : wday + 2
      last_day_of_period.days_ago(offset)
    end

    def self.last_friday(year: current_year)
      last_june_friday(year:)
    end

    def self.first_friday(year: current_year)
      last_june_friday(year:).days_ago(7)
    end

    def self.last_monday(year: current_year)
      last_june_friday(year:).days_ago(4)
    end

    def self.first_monday(year: current_year)
      last_june_friday(year:).days_ago(11)
    end

    def self.period_collection(school_year:)
      hash = {
        full_time: { start_day: first_monday, end_day: last_friday },
        week_1: { start_day: first_monday, end_day: first_friday },
        week_2: { start_day: last_monday, end_day: last_friday }
      }
      hash.each_value do |value|
        value.merge!(
          month: 'juin',
          year: school_year,
          start: value[:start_day].mday,
          end: value[:end_day].mday
        )
      end
      hash
    end

    def self.selectable_from_now_until_end_of_school_year
      both_weeks.where('id >= ?', Week.current.id)
    end
  end
end
