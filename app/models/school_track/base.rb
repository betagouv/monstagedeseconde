module SchoolTrack
  class Base
    SWITCH_MONTH = SchoolYear::Current::MONTH_OF_YEAR_SHIFT
    SWITCH_DAY = SchoolYear::Current::FIRST

    def self.current_year
      delta = Date.today < Date.new(Date.today.year, SWITCH_MONTH, SWITCH_DAY) ? 0 : 1
      Date.today.year + delta
    end
  end
end
