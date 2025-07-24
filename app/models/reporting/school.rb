# frozen_string_literal: true

module Reporting
  # wrap reporting for School
  class School < ApplicationRecord
    # include FindableWeek
    include SchoolUsersAssociations

    def readonly?
      true
    end
    PAGE_SIZE = 100

    has_many :class_rooms
    belongs_to :department, optional: true

    has_many :internship_applications, through: :students do
      def approved
        where(aasm_state: :approved)
      end
    end

    has_many :school_managers, -> { where(role: :school_manager) },
             through: :user_schools,
             source: :user,
             class_name: 'Users::SchoolManagement'

    def school_manager
      school_managers.first
    end

    scope :count_with_school_manager, lambda {
      joins(:school_managers)
        .distinct('schools.id')
        .count
    }

    scope :with_school_manager, lambda {
      left_joins(:school_managers)
        .group('schools.id')
    }

    scope :without_school_manager, lambda {
      where.missing(:school_managers)
    }

    scope :with_manager_simply, -> { joins(:school_managers) }

    scope :by_subscribed_school, lambda { |subscribed_school:|
      case subscribed_school.to_s
      when 'true'
        with_manager_simply
      when 'false'
        without_school_manager
      else
        all
      end
    }

    paginates_per PAGE_SIZE

    def total_student_count
      students_not_anonymized.size
    end

    def total_student_with_confirmation_count
      students_not_anonymized.select(&:confirmed_at?)
                             .size
    end

    def total_student_confirmed
      students_not_anonymized.select(&:confirmed?)
                             .size
    end

    def total_student_count
      students_not_anonymized.size
    end

    def school_manager?
      users.select { |user| user.school_manager? }
           .size
           .positive?
    end

    def total_teacher_count
      users.select { |user| user.teacher? }
           .size
    end

    def total_approved_internship_applications_count(school_year:)
      query = internship_applications.approved
      if school_year
        query = query.where('internship_applications.created_at >= ?',
                            SchoolYear::Floating.new_by_year(year: school_year.to_i).offers_beginning_of_period)
      end
      if school_year
        query = query.where('internship_applications.created_at <= ?',
                            SchoolYear::Floating.new_by_year(year: school_year.to_i).deposit_end_of_period)
      end
      query.size
    end

    private

    def students_not_anonymized
      users.select(&:student?)
           .reject(&:anonymized)
    end
  end
end
