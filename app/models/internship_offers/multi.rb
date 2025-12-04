module InternshipOffers
  class Multi < InternshipOffer
    belongs_to :multi_corporation
    has_many :corporations, through: :multi_corporation
    has_one :multi_coordinator

    def from_multi? = true
    
  end
end