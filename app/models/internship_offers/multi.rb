module InternshipOffers
  class Multi < InternshipOffer
    belongs_to :multi_corporation
    has_many :corporations, through: :multi_corporation
    has_one :multi_coordinator

    def from_multi? = true
    def display_city = corporations.first&.corporation_city || city
    
    # Validations to satisfy InternshipOffer requirements
    validates :coordinates, presence: true
    validates :entreprise_coordinates, presence: true

    def has_weeks_after_school_year_start?
      start_week = Week.current_year_start_week
      weeks.any? { |week| week.id.in?(Week.after_week(week: start_week).ids) }
    end
  end
end