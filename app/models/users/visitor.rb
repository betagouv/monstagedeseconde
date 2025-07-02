# frozen_string_literal: true

module Users
  class Visitor < User
    def readonly?
      true
    end

    def compute_weeks_lists
      @school_weeks_list = Week.both_school_track_selectable_weeks
      @preselected_weeks_list = Week.both_school_track_selectable_weeks

      [@school_weeks_list, @preselected_weeks_list]
    end
  end
end
