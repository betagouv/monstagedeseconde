module SchoolTrack
  class Troisieme < Base
    def self.selectable_on_school_year_weeks(year: current_year)
      limits_hash = SchoolYear::Floating.new_by_year(year: year).from_now_to_end_of_current_troisieme_year_limits
      Week.from_date_to_date(**limits_hash)
    end

    def self.first_week(year: current_year)
      self.selectable_on_school_year_weeks(year: current_year).first
    end

    def self.last_week(year: current_year)
      self.selectable_on_school_year_weeks(year: current_year).last
    end

    def self.selectable_from_now_until_end_of_school_year
      selectable_on_school_year_weeks.where("id >= ?", Week.current.id)
    end
  end
end
