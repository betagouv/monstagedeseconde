module InternshipAgreements
  class MultiInternshipAgreement < InternshipAgreement
    # Includes

    # Associations
    belongs_to :coordinator, class_name: 'User'

    # Validations
    validate :at_least_daily_hours_or_weekly_hours

    validates :coordinator, presence: true
    validates :access_token, presence: true, length: { is: 20 }
    validates :activity_scope, presence: true, length: { maximum: 1500 }
    validates :uuid, presence: true, uniqueness: true
    
    with_options if: :enforce_school_manager_validations? do
      validates :organisation_representative_role, presence: true, length: { maximum: 150 }
      validates :student_address, presence: true, length: { maximum: 170 }
      validates :school_representative_phone, presence: true, length: { maximum: 20 }
      validates :student_full_name, presence: true, length: { minimum: 5, maximum: 100 }
      validates :student_legal_representative_email, presence: true, length: { maximum: 100 }
      validates :student_legal_representative_full_name, presence: true, length: { maximum: 100 }
      validates :student_legal_representative_phone, presence: true, length: { maximum: 20 }
      validates :school_representative_email, presence: true, length: { maximum: 100 }
      validates :student_birth_date, presence: true
      validates :student_full_name, presence: true, length: { maximum: 100 }
    end

    # Callbacks

    # Scopes
    # (scopes can be added here as needed)

    

    # Methods
    # (custom methods can be added here as needed)


  end
end
