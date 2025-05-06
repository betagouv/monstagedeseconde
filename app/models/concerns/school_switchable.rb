# frozen_string_literal: true

module SchoolSwitchable
  extend ActiveSupport::Concern

  included do
    has_many :user_schools, foreign_key: :user_id, dependent: :destroy
    has_many :schools, through: :user_schools
    belongs_to :current_school, class_name: 'School', foreign_key: :school_id, optional: true
  end

  def school
    return current_school if current_school.present?

    super
  end

  def switch_school(school_id)
    return false unless schools.exists?(id: school_id)

    update(school_id: school_id)
  end
end
