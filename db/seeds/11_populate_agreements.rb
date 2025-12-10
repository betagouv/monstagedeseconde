
def populate_agreements
  troisieme_applications_offers = InternshipApplications::WeeklyFramed.approved
  agreement_0 = Builders::InternshipAgreementBuilder.new(user: troisieme_applications_offers[0].employer)
                                                    .new_from_application(troisieme_applications_offers[0])
  agreement_0.aasm_state = :draft
  agreement_0.save!

  agreement_1 = Builders::InternshipAgreementBuilder.new(user: troisieme_applications_offers[1].employer)
                                                    .new_from_application(troisieme_applications_offers[1])
  agreement_1.aasm_state = :started_by_school_manager
  agreement_1.save!

  # agreement_2 = Builders::InternshipAgreementBuilder.new(user: troisieme_applications_offers[2].employer)
  #                                                   .new_from_application(troisieme_applications_offers[2])
  # agreement_2.school_manager_accept_terms = false
  # agreement_2.employer_accept_terms = true
  # agreement_2.aasm_state = :completed_by_employer
  # agreement_2.save!
end

call_method_with_metrics_tracking(%i[ populate_agreements ])
