
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
  validates :weeks, presence: true

  
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
  
  def weeks_count
    multi_planning_weeks.count
  end

  def coordinates
    # Dummy coordinates for now as MultiCoordinator doesn't store them
    # OpenStruct.new(latitude: 0, longitude: 0)
    
    # We need to find coordinates from multi_coordinator -> multi_corporation -> corporations.first
    # or fallback to Paris
    
    # But MultiPlanning doesn't have direct access to MultiCorporation in its association chain easily
    # It has multi_coordinator
    
    # Let's try to get coordinates from the first corporation of the multi_coordinator
    first_corp = multi_coordinator&.multi_corporation&.corporations&.first
    coords = first_corp&.internship_coordinates

    if coords.present?
      # If it's a Hash (legacy or wrong save), convert to RGeo
      if coords.is_a?(Hash)
        lat = coords['latitude'] || coords[:latitude]
        lon = coords['longitude'] || coords[:longitude]
        return RGeo::Geographic.spherical_factory(srid: 4326).point(lon.to_f, lat.to_f)
      end
      coords
    else
      # Default to Paris
      RGeo::Geographic.spherical_factory(srid: 4326).point(2.3522, 48.8566)
    end
  end
end
