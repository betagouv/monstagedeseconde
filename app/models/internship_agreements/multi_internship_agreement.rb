module InternshipAgreements
  class MultiInternshipAgreement < InternshipAgreement
    after_commit :create_unsigned_corporation_internship_agreements, on: :create
    # Includes

    # Associations
    has_many :corporation_internship_agreements, dependent: :destroy, foreign_key: :internship_agreement_id
    has_many :corporations, through: :corporation_internship_agreements

    # Callbacks

    # Delegations
    delegate :student, to: :internship_application
    delegate :internship_offer, to: :internship_application
    delegate :multi_corporation, to: :internship_offer

    # Scopes
    # (scopes can be added here as needed)


    # Methods
    # (custom methods can be added here as needed)
    def send_multi_signature_reminder_emails!
      corporation_internship_agreements.where(signed: false).each do |cia|
        cia.corporation
           .send_multi_agreement_signature_invitation(
              internship_agreement_ids: [cia.internship_agreement_id]
            )
      end
    end

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
