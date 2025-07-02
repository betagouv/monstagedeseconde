module SchoolTrack
  class Base
    # test : see if direct and duplicated code can remove false negative tests
    SWITCH_MONTH = 7 # SchoolYear::Current::MONTH_OF_YEAR_SHIFT
    SWITCH_DAY = 1 # SchoolYear::Current::FIRST

    # YEAR_START             = 2019
    # MONTH_OF_YEAR_SHIFT    = 7
    # MONTH_OF_3EME_YEAR_END = 6
    # SEPTEMBER              = 9
    # FIRST                  = 1

    def self.current_year
      delta = Date.today.month <= SWITCH_MONTH ? 0 : 1
      Date.today.year + delta
    end
  end
end
