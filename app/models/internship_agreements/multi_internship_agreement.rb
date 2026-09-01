module InternshipAgreements
  class MultiInternshipAgreement < InternshipAgreement
    # Includes

    # Associations
    # Conservées pour les multi "historiques" (legacy_multi?) : 1 convention regroupant
    # N corporations. Le nouveau flux "stage partagé" crée 1 convention par corporation
    # (rattachée via internship_agreements.corporation_id) et n'alimente plus ces tables.
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

    def pre_selected_for_signature?
      !!pre_selected_for_signature
    end
  end
end
