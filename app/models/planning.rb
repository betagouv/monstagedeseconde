# TODO: remove if not mandatory
# require 'sti_preload'
class Planning < ApplicationRecord
  include StepperProxy::Planning

  # Following is specific to planning and shall not be part of internship_offer

  # Relations
  belongs_to :entreprise
  has_many :planning_weeks, dependent: :destroy
  has_many :weeks, through: :planning_weeks

  # Validations

  # Temp accessors
  attr_accessor :all_year_long, :grade_3e4e

  def weeks_count
    planning_weeks.to_a.count
  end

  def is_fully_editable? = true
end
