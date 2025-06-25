module SchoolTrack
  class Base
    SWITCH_MONTH = 7
    SWITCH_DAY = 1

    def self.current_year
      delta = Date.today.month <= SWITCH_MONTH ? 0 : 1
      Date.today.year + delta
    end
  end
end
