# frozen_string_literal: true

module SchoolSwitchable
  extend ActiveSupport::Concern

  included do
    has_many :user_schools, foreign_key: :user_id, dependent: :destroy
    has_many :schools, through: :user_schools
    belongs_to :current_school, class_name: 'School', foreign_key: :school_id, optional: true

    after_save :ensure_primary_school_in_user_schools, if: :saved_change_to_school_id?
  end

  def school
    return current_school if current_school.present?

    super
  end

  def switch_school(school_id)
    return false unless schools.exists?(id: school_id)

    update(school_id: school_id)
  end

  private

  def ensure_primary_school_in_user_schools
    return if school_id.blank?

    UserSchool.find_or_create_by!(user_id: id, school_id: school_id)
  end
end
