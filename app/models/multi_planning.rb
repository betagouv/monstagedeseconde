
class MultiPlanning < ApplicationRecord
  belongs_to :multi_coordinator
  belongs_to :school, optional: true

  has_many :multi_planning_grades, dependent: :destroy
  has_many :grades, through: :multi_planning_grades

  has_many :multi_planning_reserved_schools, dependent: :destroy
  has_many :schools, through: :multi_planning_reserved_schools

  has_many :multi_planning_weeks, dependent: :destroy
  has_many :weeks, through: :multi_planning_weeks

  # Virtual attributes for form
  attr_accessor :period_field, :internship_type, :all_year_long

  validates :max_candidates, numericality: { only_integer: true, greater_than: 0 }
  validates :lunch_break, length: { maximum: 250 }, presence: true
  validates :rep, inclusion: { in: [true, false] }
  validates :qpv, inclusion: { in: [true, false] }

  
  # Helper to determine if we are offering to college or lycee
  def grade_college
    grades.any?(&:troisieme_or_quatrieme?)
  end

  def grade_2e
    grades.any?(&:seconde?)
  end

  # Setter for form handling (virtual attributes)
  def grade_college=(value)
    if value == '1' || value == true
      self.grade_ids = (grade_ids + Grade.troisieme_et_quatrieme.ids).uniq
    else
      self.grade_ids = (grade_ids - Grade.troisieme_et_quatrieme.ids).uniq
    end
  end

  def grade_2e=(value)
    seconde_id = Grade.seconde.id
    if value == '1' || value == true
      self.grade_ids = (grade_ids + [seconde_id]).uniq
    else
      self.grade_ids = (grade_ids - [seconde_id]).uniq
    end
  end

  # Methods for partial compatibility
  def daily_planning?
    daily_hours.present? && daily_hours.values.flatten.any?(&:present?)
  end

  def weekly_planning?
    !daily_planning?
  end
  
  def is_fully_editable?
    true
  end
  
  def coordinates
    # Dummy coordinates for now as MultiCoordinator doesn't store them
    OpenStruct.new(latitude: 0, longitude: 0)
  end
end
