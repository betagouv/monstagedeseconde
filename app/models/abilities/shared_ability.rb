# frozen_string_literal: true

module Abilities
  module SharedAbility
    def shared_signed_in_user_abilities(user:)
      can :update, user
    end

    private

    def can_read_dashboard_students_internship_applications(user:)
      can [ :dashboard_index ], Users::Student do |student|
        student.id == user.id || student_managed_by?(student:, user:)
      end

      can [ :dashboard_show ], InternshipApplication do |internship_application|
        internship_application.student.id == user.id ||
          student_managed_by?(student: internship_application.student, user:)
      end
    end

    def student_managed_by?(student:, user:)
      student.school_id == user.school_id &&
        user.is_a?(Users::SchoolManagement)
    end

    def can_create_and_manage_account(user:)
      can :show, :account
      can %i[show edit update], User
      yield if block_given?
    end

    def can_manage_school(user:)
      can %i[
        show
        manage_school_users
        index
      ], ClassRoom do |class_room|
        class_room.school_id == user.school_id
      end
      can :change, ClassRoom do |class_room|
        class_room.school_id == user.school_id && !user.school_manager?
      end

      can [ :show_user_in_school ], User do |user|
        user.school
            .users
            .map(&:id)
            .map(&:to_i)
            .include?(user.id.to_i)
      end
      yield if block_given?
    end

    def application_related_to_team?(user:, internship_application:)
      author_id = internship_application.internship_offer.employer_id
      user.team.id_in_team?(author_id)
    end

    def offer_belongs_to_team?(user:, internship_offer:)
      internship_offer.employer_id == user.team_id
    end

    def renewable?(internship_offer:, user:)
      main_condition = internship_offer.persisted? &&
                       internship_offer.employer_id == user.id
      if main_condition
        school_year_start = SchoolYear::Current.new.offers_beginning_of_period
        internship_offer.last_date <= school_year_start
      else
        false
      end
    end

    def duplicable?(internship_offer:, user:)
      internship_offer.persisted? &&
        internship_offer.employer_id == user.id
    end

    def read_employer_name?(internship_offer:)
      if internship_offer.employer.type == "Users::Operator"
        operator = internship_offer.employer.try(:operator)
        if operator.present? && operator.masked_data
          false
        elsif operator.present? && operator.departments.any?
          !internship_offer.zipcode[0..1].in?(operator.departments.map(&:code))
        else
          true
        end
      else
        true
      end
    end

    def employers_only?
      ENV.fetch("EMPLOYERS_ONLY", false) == "true"
    end
  end
end
