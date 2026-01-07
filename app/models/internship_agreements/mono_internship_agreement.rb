module InternshipAgreements
  class MonoInternshipAgreement < InternshipAgreement
    
    # Validations


    with_options if: :enforce_employer_validations? do
      validates :date_range,
                :tutor_role,
                :entreprise_address,
                presence: true
      validates :organisation_representative_full_name,
                :tutor_full_name,
                presence: true,
                length: { minimum: 5, maximum: 100 }
      validates :siret, length: { is: 14 }, allow_nil: true
      validates :activity_scope, presence: true, length: { maximum: 1500 }
      validate :valid_working_hours_fields
      validate :at_least_daily_hours_or_weekly_hours

      validates :organisation_representative_role,
                presence: true,
                length: { minimum: 3, maximum: 150 }
    end
  end
end