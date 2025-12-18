class Corporation < ApplicationRecord

  #Callback
  # before_create :generate_uuid
  # extra attributes not in DB
  attr_accessor :internship_agreement_uuids

  #Associations
  belongs_to :multi_corporation
  belongs_to :sector, optional: true
  has_many :corporation_internship_agreements, dependent: :destroy
  has_many :internship_agreements, through: :corporation_internship_agreements

  # Delegations
  delegate :coordinator, to: :multi_corporation
  # Validations
  validates :siret, presence: true, length: { is: 14 }

  # Structure Accueillante
  validates :corporation_name, presence: true, length: { maximum: 120 }
  validates :corporation_address, presence: true, length: { maximum: 250 }
  validates :corporation_city, presence: true, length: { maximum: 60 }
  validates :corporation_zipcode, presence: true, length: { maximum: 6 }
  validates :corporation_street, presence: true, length: { maximum: 300 }

  # Internship Address
  validates :internship_city, presence: true, length: { maximum: 60 }
  validates :internship_zipcode, presence: true, length: { maximum: 6 }
  validates :internship_street, presence: true, length: { maximum: 300 }
  validates :internship_phone, length: { maximum: 20 }, allow_blank: true

  # Employer / Signatory (Representative)
  validates :employer_name, presence: true, length: { maximum: 150 }
  validates :employer_role, presence: true, length: { maximum: 120 }
  validates :employer_email, presence: true, length: { maximum: 120 }, format: { with: Devise.email_regexp }
  # validates :employer_phone, presence: true, length: { maximum: 20 }

  # Tutor
  validates :tutor_name, presence: true, length: { maximum: 150 }
  validates :tutor_role_in_company, presence: true, length: { maximum: 250 }
  validates :tutor_email, presence: true, length: { maximum: 120 }, format: { with: Devise.email_regexp }
  # validates :tutor_phone, presence: true, length: { maximum: 20 }

  validates :sector_id, presence: true

  def presenter
    @presenter ||= Presenters::Corporation.new(self)
  end

  def send_multi_agreement_signature_invitation(internship_agreement_ids: [])
    # return if internship_agreement_ids.empty? Should Never Occur

    EmployerMailer.multi_internship_agreement_signature_invitation_email(
      internship_agreement_ids: internship_agreement_ids,
      corporation_id: id
    ).deliver_later
  end
end
