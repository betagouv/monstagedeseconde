module StepperProxy
  module Planning
    extend ActiveSupport::Concern
    # common to planning and internship_offer

    included do
      after_initialize :set_default_values
      before_save :set_default_values

      # Associations
      has_many :planning_grades,
               dependent: :destroy,
               class_name: 'PlanningGrade',
               foreign_key: :planning_id
      has_many :grades, through: :planning_grades
      has_many :internship_offer_weeks
      has_many :weeks, through: :internship_offer_weeks
      belongs_to :school, optional: true

      # Validations
      validates :max_candidates,
                numericality: { only_integer: true,
                                greater_than: 0,
                                less_than_or_equal_to: InternshipOffer::MAX_CANDIDATES_HIGHEST }
      validates :weeks, presence: true, on: :update, unless: :maintenance_conditions?
      # if not API, validate enough weeks
      validate :enough_weeks unless :from_api
      validate :at_least_one_grade

      # methods common to planning and internship_offer but not for API
      def enough_weeks
        return if weeks.empty?

        error_message = 'Indiquez la ou les semaine où vous accueillerez des élèves'
        errors.add(:max_candidates, error_message)
      end

      def available_weeks
        both_tracks_weeks = Week.both_school_track_selectable_weeks
        return both_tracks_weeks unless respond_to?(:weeks)
        return both_tracks_weeks unless persisted?
        return both_tracks_weeks if weeks&.first.nil?

        school_year = SchoolYear::Floating.new(date: weeks.first.week_date)
        Week.selectable_on_specific_school_year(school_year:)
      end

      def all_year_long?
        all_troisieme_weeks = SchoolTrack::Troisieme.selectable_from_now_until_end_of_school_year
        offer_week_list = weeks & SchoolTrack::Troisieme.selectable_from_now_until_end_of_school_year
        all_troisieme_weeks[1..-1].map(&:id).sort == offer_week_list.map(&:id).sort
      end

      private

      def maintenance_conditions? = false

      def set_default_values
        self.max_candidates ||= 1
        self.max_students_per_group = max_candidates
      end

      def at_least_one_grade
        return if grades.present?

        errors.add(:grades, 'Vous devez sélectionner au moins une classe')
      end
    end
  end
end
