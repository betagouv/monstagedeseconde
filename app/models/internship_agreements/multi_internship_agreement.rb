module InternshipAgreements
  class MultiInternshipAgreement < InternshipAgreement
    after_commit :create_unsigned_corporation_internship_agreements, on: :create
    # Includes

    # Associations
    has_many :corporation_internship_agreements, dependent: :destroy
    has_many :corporations, through: :corporation_internship_agreements

    # Callbacks

    # Delegations
    delegate :student, to: :internship_application
    delegate :internship_offer, to: :internship_application

    # Scopes
    # (scopes can be added here as needed)


    # Methods
    # (custom methods can be added here as needed)

    private

    def create_unsigned_corporation_internship_agreements
      internship_offer.multi_corporation.corporations.each do |corporation|
        CorporationInternshipAgreement.find_or_create_by!(
          corporation_id: corporation.id,
          internship_agreement_id: self.id,
          signed: false
        )
      end
    end
  end
end
