module SchoolTrack
  class Troisieme < Base
    def self.first_week(year: current_year)
      SchoolYear::Floating.new_by_year(year: year).offers_beginning_of_period_week
    end

    def self.last_week_of_june(year: current_year)
      SchoolYear::Floating.new_by_year(year: year).offers_end_of_period_week
    end

    def self.last_week(year: current_year)
      last_week_of_june(year: current_year)
    end

    def self.selectable_on_school_year_weeks
      start_id = first_week.id
      end_id = last_week.id

      Week.where(id: (start_id..end_id))
    end

    def self.selectable_from_now_until_end_of_school_year
      selectable_on_school_year_weeks.where('id >= ?', Week.current.id)
    end
  end
end
