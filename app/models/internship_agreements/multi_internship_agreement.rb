module InternshipAgreements
  class MultiInternshipAgreement < InternshipAgreement
    # Includes

    # Associations

    # Callbacks

    # Delegations
    delegate :student, to: :internship_application
    delegate :internship_offer, to: :internship_application
    # delegate :employer, to: :internship_offer

    # Scopes
    # (scopes can be added here as needed)


    # Methods
    # (custom methods can be added here as needed)


  end
end
