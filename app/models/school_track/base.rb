module SchoolTrack
  class Base
    def self.current_year
      SchoolYear::Current.new.year_in_june
    end
  end
end
