module Dto
  class PlanningAdapter
    delegate :grades, to: :@instance

    PERIOD = {
      two_weeks: 2,
      first_week: 11,
      second_week: 12
    }.freeze

    def manage_planning_associations
      manage_grades
      manage_weeks
      instance.employer_id = current_user.id
      self
    end

    def employer_chose_whole_year?
      params[:all_year_long] == 'true'
    end

    def period_field
      params[:period_field].to_i
    end

    def manage_grades
      return if !params_offer_for_seconde? && !params_offer_for_troisieme_or_quatrieme? # grades is unchanged

      instance.grades = []
      instance.grades.append Grade.troisieme_et_quatrieme.to_a if params_offer_for_troisieme_or_quatrieme?
      return unless params_offer_for_seconde?

      instance.grades.append Grade.seconde
    end

    def manage_weeks
      troisieme_only = (instance.grades.map(&:id) - [Grade.troisieme, Grade.quatrieme].map(&:id)).empty?
      seconde_only = (instance.grades.map(&:id) - [Grade.seconde.id]).empty?
      troisieme_and_seconde = !troisieme_only && !seconde_only
      if seconde_only
        manage_seconde_weeks
        keep_weeks(:seconde_only)
      elsif troisieme_only
        manage_troisieme_weeks
        keep_weeks(:troisieme_only)
      elsif troisieme_and_seconde
        manage_troisieme_weeks
        manage_seconde_weeks
      end
    end

    def remove_seconde_weeks = reject_weeks(Week.seconde_weeks)
    def remove_troisieme_weeks = reject_weeks(Week.troisieme_weeks)

    def keep_weeks(kept_type)
      case kept_type
      when :seconde_only
        instance.weeks = instance.weeks.reject do |week|
          !week.id.in?(Week.seconde_weeks.map(&:id))
        end
      when :troisieme_only
        instance.weeks = instance.weeks.reject do |week|
          week.id.in?(Week.seconde_weeks.map(&:id))
        end
      end
    end

    def manage_seconde_weeks
      return if period_field.blank? && instance.persisted?

      weeks = []
      weeks << SchoolTrack::Seconde.first_week if period_field.in?([PERIOD[:two_weeks], PERIOD[:first_week]])
      weeks << SchoolTrack::Seconde.second_week if period_field.in?([PERIOD[:two_weeks], PERIOD[:second_week]])
      add_weeks_to_planning(weeks)
    end

    def manage_troisieme_weeks
      available_weeks = Week.troisieme_selectable_weeks
      add_weeks_to_planning(available_weeks) if employer_chose_whole_year?
    end

    def add_weeks_to_planning(weeks)
      return if weeks.empty?

      instance.week_ids = (instance.weeks << weeks).uniq.map(&:id)
    end

    def reject_weeks(weeks)
      instance.weeks = instance.weeks.reject do |week|
        week.id.in?(weeks.map(&:id))
      end
    end

    def params_offer_for_seconde? = check_grade?(:grade_2e)
    def params_offer_for_troisieme_or_quatrieme? = check_grade?(:grade_college)

    def check_grade?(grade)
      params[grade].presence.to_i == 1
    end

    attr_reader :params, :current_user
    attr_accessor :available_weeks, :instance

    private

    def initialize(instance:, params:, current_user:)
      @instance = instance
      @params = params
      @available_weeks = []
      @current_user = current_user
    end
  end
end
