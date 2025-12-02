module InternshipOffers
  class Multi < InternshipOffer
    has_many :corporations
    # belongs_to :coordinator, class_name: 'Users::Employer'

    def from_multi? = true
    
  end
end