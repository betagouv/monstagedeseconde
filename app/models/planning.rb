# TODO: remove sti_preload if not mandatory
# require 'sti_preload'
class Planning < ApplicationRecord
  include StepperProxy::Planning

  # Following is specific to planning and shall not be part of internship_offer

  # Relations
  belongs_to :entreprise
  has_many :planning_weeks,
           dependent: :destroy,
           foreign_key: :planning_id,
           inverse_of: :planning
  has_many :weeks, through: :planning_weeks
  has_many :planning_grades,
           dependent: :destroy,
           foreign_key: :planning_id,
           inverse_of: :planning
  has_many :grades, through: :planning_grades
  has_one :internship_offer, dependent: :destroy

  # Callbacks

  # Validations

  # accessors
  attr_accessor :all_year_long,
                :specific_weeks,
                :grade_college,
                :grade_2e,
                :period_field,
                :internship_type

  def weeks_count
    planning_weeks.to_a.count
  end

  def is_fully_editable? = true

  def weekly_planning?
    weekly_hours.any?(&:present?)
  end

  def daily_planning?
    daily_hours.except('samedi').values.flatten.any? { |v| !v.blank? }
  end

  def coordinates
    entreprise.try(:internship_occupation).try(:coordinates) || { longitude: 0, latitude: 0 }
  end
end
