
def populate_agreements
  troisieme_applications_offers = InternshipApplications::WeeklyFramed.troisieme.approved
  agreement_0 = Builders::InternshipAgreementBuilder.new(user: troisieme_applications_offers[0].employer)
                                                    .new_from_application(troisieme_applications_offers[0])
  agreement_0.aasm_state = :draft
  agreement_0.save!

  agreement_1 = Builders::InternshipAgreementBuilder.new(user: troisieme_applications_offers[0].employer)
                                                    .new_from_application(troisieme_applications_offers[0])
  agreement_1.aasm_state = :started_by_school_manager
  agreement_1.save!

  seconde_applications_applications = InternshipApplication.seconde.approved
  seconde_multi_applications = seconde_applications_applications.select { |ia| ia.internship_offer.from_multi? }
  employer = seconde_applications_applications[0].internship_offer.employer

  agreement_2 = Builders::InternshipAgreementBuilder.new(user: employer)
                                                    .new_from_application(seconde_applications_applications[0])
  agreement_2.aasm_state = :started_by_employer
  agreement_2.save!

  agreement_3 = Builders::InternshipAgreementBuilder.new(user: employer)
                                                    .new_from_application(seconde_multi_applications[0], multi_agreements: true)
  if agreement_3.valid?
    agreement_3.save! #draft state by default
  else
    puts "Agreement 3 is invalid: #{agreement_3.errors.full_messages.join(', ')}"
  end
end

call_method_with_metrics_tracking(%i[ populate_agreements ])
