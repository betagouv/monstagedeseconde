module UserWithSchool
  extend ActiveSupport::Concern

  included do
    belongs_to :school, optional: true

    def compute_weeks_lists
      weeks_chosen_by_school = try(:school).try(:weeks) || []
      school_weeks = determine_school_weeks(weeks_chosen_by_school) || []
      preselected_weeks = determine_preselected_weeks(weeks_chosen_by_school)
      [school_weeks, preselected_weeks]
    end

    def determine_school_weeks(weeks_chosen_by_school)
      school_weeks = try(:school).try(:off_constraint_school_weeks, try(:grade))

      if weeks_chosen_by_school.empty? && school_weeks.nil?
        Week.both_school_track_selectable_weeks
      else
        weeks_chosen_by_school || school_weeks
      end
    end

    def determine_preselected_weeks(weeks_chosen_by_school)
      return Week.both_school_track_selectable_weeks if weeks_chosen_by_school.empty?

      weeks_chosen_by_school
    end
  end
end
