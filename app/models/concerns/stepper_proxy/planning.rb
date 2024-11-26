module StepperProxy
  module Planning
    extend ActiveSupport::Concern
    # common to planning and internship_offer

    included do
      after_initialize :set_default_values

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
      validates :max_students_per_group,
                numericality: { only_integer: true,
                                greater_than: 0,
                                less_than_or_equal_to: :max_candidates,
                                message: "Le nombre maximal d'élèves par groupe ne peut pas dépasser le nombre maximal d'élèves attendus dans l'année" }
      validates :weeks, presence: true
      # if not API, validate enough weeks
      validate :enough_weeks unless :from_api
      validate :at_least_one_grade

      # methods common to planning and internship_offer but not for API
      def enough_weeks
        return if weeks.empty?
        return if skip_enough_weeks_validation?
        return if max_candidates / max_students_per_group.to_f <= weeks.size

        error_message = 'Le nombre maximal d\'élèves est trop important par ' \
                        'rapport au nombre de semaines de stage choisi. Ajoutez des ' \
                        'semaines de stage ou augmentez la taille des groupes  ' \
                        'ou diminuez le nombre de ' \
                        'stagiaires prévus.'
        errors.add(:max_candidates, error_message)
      end

      def is_individual?
        max_students_per_group == 1
      end

      def skip_enough_weeks_validation?
        @skip_enough_weeks_validation ||= false
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
        Week.selectable_from_now_until_end_of_school_year.in?(weeks)
      end

      private

      def set_default_values
        self.max_candidates ||= 1
        self.max_students_per_group ||= 1
      end

      def at_least_one_grade
        return if grades.present?

        errors.add(:grades, 'Vous devez sélectionner au moins une classe')
      end
    end
  end
end
