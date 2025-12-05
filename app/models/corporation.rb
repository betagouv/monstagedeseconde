class Corporation < ApplicationRecord
  belongs_to :multi_corporation
  belongs_to :sector, optional: true

  # Validations
  validates :siret, presence: true, length: { is: 14 }
  validates :city, presence: true, length: { maximum: 60 }
  validates :zipcode, presence: true, length: { maximum: 6 }
  validates :street, presence: true, length: { maximum: 300 }

  # Internship Address
  validates :internship_city, presence: true, length: { maximum: 60 }
  validates :internship_zipcode, presence: true, length: { maximum: 6 }
  validates :internship_street, presence: true, length: { maximum: 300 }
  validates :internship_phone, presence: true, length: { maximum: 20 }

  # Employer / Signatory
  validates :employer_name, presence: true, length: { maximum: 150 }
  validates :employer_role, presence: true, length: { maximum: 250 }
  validates :employer_email, presence: true, length: { maximum: 120 }, format: { with: Devise.email_regexp }
  validates :employer_phone, presence: true, length: { maximum: 20 }

  # Tutor
  validates :tutor_name, presence: true, length: { maximum: 150 }
  validates :tutor_role_in_company, presence: true, length: { maximum: 250 }
  validates :tutor_email, presence: true, length: { maximum: 120 }, format: { with: Devise.email_regexp }
  validates :tutor_phone, presence: true, length: { maximum: 20 }
  
  validates :sector_id, presence: true
end
