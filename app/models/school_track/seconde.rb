module SchoolTrack
  class Seconde
    # hash computing two last week of june hash with year as key where year starts from 2022 to 2029
    
    def self.current_period_data
      period_collection(school_year: current_year)
    end

    def self.current_period_labels
      period_labels(school_year: current_year)
    end

    def self.current_year
      SchoolYear::Current.new.year_in_june
    end

    def self.period_labels(school_year:)
      period_collection(school_year:).transform_values do |time_frame|
        prefix = time_frame[:end] - time_frame[:start] > 10 ? '2 semaines' : '1 semaine'
        "#{prefix} - du #{time_frame[:start]} au #{time_frame[:end]} #{time_frame[:month]} #{time_frame[:year]}"
      end
    end

    private

    def self.last_june_friday(year:)
      last_day_of_june = Date.new(year, 6, 30)
      wday = last_day_of_june.wday
      offset = wday >= 5 ? wday - 5 : wday + 2
      last_day_of_june.days_ago(offset)
    end

    def self.period_collection(school_year:)
      last_friday = last_june_friday(year: school_year)
      first_friday = last_friday.days_ago(7)
      last_monday = last_friday.days_ago(4)
      first_monday = last_friday.days_ago(11)

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
  end
end
