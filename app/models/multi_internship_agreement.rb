class MultiInternshipAgreement < ApplicationRecord
  # Includes
  # (Any included modules can be listed here)

  # Associations
  belongs_to :internship_application
  belongs_to :coordinator, class_name: 'User'
  has_many :signatures, dependent: :destroy

  # Validations
  validates :internship_application, presence: true
  validates :coordinator, presence: true
  validates :organisation_representative_role, presence: true, length: { maximum: 150 }
  validates :student_address, presence: true, length: { maximum: 170 }
  validates :school_representative_phone, presence: true, length: { maximum: 20 }
  validates :student_full_name, presence: true, length: { minimum: 5, maximum: 100 }
  validates :student_legal_representative_email, presence: true, length: { maximum: 100 }
  validates :student_legal_representative_full_name, presence: true, length: { maximum: 100 }
  validates :student_legal_representative_phone, presence: true, length: { maximum: 20 }
  validates :school_representative_email, presence: true, length: { maximum: 100 }
  validates :student_birth_date, presence: true
  validates :access_token, presence: true, length: { is: 16 }
  validates :student_full_name, presence: true, length: { maximum: 100 }
  validates :activity_scope, presence: true, length: { maximum: 1500 }

  validate :at_least_daily_hours_or_weekly_hours

  # Callbacks
  # (callbacks can be added here as needed)

  # Scopes
  # (scopes can be added here as needed)

  # Methods
  # (custom methods can be added here as needed)
  # 
  private

  def at_least_daily_hours_or_weekly_hours
    if daily_hours.blank? && weekly_hours.blank?
      errors.add(:base, "Vous devez fournir soit les heures hebdomadaires, soit les heures journalières.")
    end
  end
  # End of class
end
