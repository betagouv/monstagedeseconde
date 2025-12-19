class CorporationInternshipAgreement < ApplicationRecord
  belongs_to :corporation, optional: false
  belongs_to :internship_agreement, optional: false

  # Validations
  validates :corporation, presence: true
  validates :internship_agreement, presence: true
  validates :signed, inclusion: { in: [true, false] }

  #scopes
  scope :signed, -> { where(signed: true) }
  scope :unsigned, -> { where(signed: false) }

  # methods
  def fetch_corporations
    Corporation.joins(:corporation_internship_agreements)
               .where(corporation_internship_agreements: { internship_agreement_id: internship_agreement_id })
  end

  def fetch_internship_agreements
    InternshipAgreement.joins(:corporation_internship_agreements)
                       .where(corporation_internship_agreements: { corporation_id: corporation_id })
  end

end
