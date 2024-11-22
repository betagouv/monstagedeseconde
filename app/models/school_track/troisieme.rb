module SchoolTrack
  class Troisieme < Base
    LAST_DAY_OF_MAY = 31
    MAY = 5

    def self.last_week_of_may(year: current_year)
      Week.fetch_from(date: Date.new(year, MAY, LAST_DAY_OF_MAY))
    end

    def self.first_week(year: current_year)
      Week.fetch_from(date: Date.new(current_year - 1, 9, 6))
    end

    def self.selectable_on_school_year
      Week.where(id: first_week.id..last_week_of_may.id)
    end

    def self.selectable_from_now_until_end_of_school_year
      selectable_on_school_year.where('id >= ?',  Week.current.id)
    end
  end
end
