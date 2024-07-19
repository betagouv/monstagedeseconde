def populate_applications
  students = Users::Student.all
  offers = InternshipOffers::WeeklyFramed.all
  puts 'every offers receives an application from first stud'
  offers.first(4).each do |offer|
    puts "offer #{offer.id} receives an application from first stud"
    application = InternshipApplications::WeeklyFramed.new(
      aasm_state: offer.id.to_i.even? ? :drafted : :submitted,
      submitted_at: 10.days.ago,
      student: students.first,
      motivation_tmp: 'Au taquet',
      internship_offer: offer,
      student_phone: "060606#{(1000..9999).to_a.sample}",
      student_email: 'paul@gmail.com'
    )
    application.save! if application.valid?
  end
  #-----------------
  # 2nd student [1 approved, 1 canceled_by_employer]
  #-----------------
  puts 'second offer receive an approval --> second stud'
  application = InternshipApplications::WeeklyFramed.new(
    aasm_state: :approved,
    submitted_at: 10.days.ago,
    approved_at: 2.days.ago,
    student: students.second,
    motivation_tmp: 'Au taquet',
    internship_offer: offers.first,
    student_phone: "060606#{(1000..9999).to_a.sample}",
    student_email: 'paul@gmail.com'
  )
  application.save! if application.valid?

  puts 'second stud is canceled by employer of last internship_offer'
  application = InternshipApplications::WeeklyFramed.new(
    aasm_state: :canceled_by_employer,
    submitted_at: 10.days.ago,
    approved_at: 3.days.ago,
    canceled_at: 1.day.ago,
    student: students.second,
    motivation_tmp: 'Parce que ma société n\'a pas d\'encadrant cette semaine là',
    internship_offer: offers.second,
    student_phone: "060606#{(1000..9999).to_a.sample}",
    student_email: 'paul@gmail.com'
  )
  application.save! if application.valid?

  #-----------------
  # third student [offers.fourth approved, 1 canceled_by_student]
  #-----------------
  applications = InternshipApplications::WeeklyFramed.new(
    aasm_state: :approved,
    submitted_at: 10.days.ago,
    approved_at: 2.days.ago,
    student: students.third,
    motivation_tmp: 'Au taquet',
    internship_offer: offers.third,
    student_phone: "060606#{(1000..9999).to_a.sample}",
    student_email: 'paul@gmail.com'
  )
  applications.save! if applications.valid?

  puts 'third stud cancels his application to first offer'
  application = InternshipApplications::WeeklyFramed.new(
    aasm_state: :canceled_by_student,
    submitted_at: 10.days.ago,
    approved_at: 2.days.ago,
    canceled_at: 1.day.ago,
    student: students.third,
    motivation_tmp: 'Au taquet',
    internship_offer: offers.fourth,
    student_phone: "060606#{(1000..9999).to_a.sample}",
    student_email: 'paul@gmail.com'
  )
  application.save! if application.valid?

  #-----------------
  # 4th student [0 approved]
  #-----------------
  application = InternshipApplications::WeeklyFramed.new(
    aasm_state: :validated_by_employer,
    submitted_at: 10.days.ago,
    approved_at: 2.days.ago,
    student: students.fourth,
    motivation_tmp: 'Au taquet',
    internship_offer: offers.fourth,
    student_phone: "060606#{(1000..9999).to_a.sample}",
    student_email: 'paul@gmail.com'
  )
  application.save! if application.valid?

  application = InternshipApplications::WeeklyFramed.new(
    aasm_state: :validated_by_employer,
    submitted_at: 9.days.ago,
    validated_by_employer_at: 3.days.ago,
    student: students.fourth,
    motivation_tmp: 'Assez moyennement motivé pour ce stage',
    internship_offer: offers.fifth,
    student_phone: "060606#{(1000..9999).to_a.sample}",
    student_email: 'paul@gmail.com'
  )
  application.save! if application.valid?

  application = InternshipApplications::WeeklyFramed.new(
    aasm_state: :validated_by_employer,
    submitted_at: 29.days.ago,
    validated_by_employer_at: 23.days.ago,
    student: students.fourth,
    motivation_tmp: 'motivé moyennement pour ce stage, je vous préviens',
    internship_offer: offers[6],
    student_phone: "060606#{(1000..9999).to_a.sample}",
    student_email: 'paul@gmail.com'
  )
  application.save! if application.valid?

  application = InternshipApplications::WeeklyFramed.new(
    aasm_state: :validated_by_employer,
    submitted_at: 29.days.ago,
    student: students.fourth,
    motivation_tmp: 'motivé moyennement pour ce stage, je vous préviens',
    internship_offer: offers[0]
  )
  application.save! if application.valid?

  application = InternshipApplications::WeeklyFramed.new(
    aasm_state: :validated_by_employer,
    submitted_at: 29.days.ago,
    validated_by_employer_at: 20.days.ago,
    student: students.fourth,
    motivation_tmp: 'Très motivé pour ce stage, je vous préviens',
    internship_offer: offers[5]
  )
  application.save! if application.valid?

  #-----------------
  # 5th student [offers.third approved]
  #-----------------
  #-----------------
  # 6th student [offers.seventh approved]
  #-----------------
  #-----------------
  # 7th student [offers[4] approved]
  #-----------------
  application = InternshipApplications::WeeklyFramed.new(
    aasm_state: :approved,
    submitted_at: 23.days.ago,
    approved_at: 18.days.ago,
    student: students[6],
    motivation_tmp: 'Très motivé pour ce stage, je vous préviens',
    internship_offer: offers[4]
  )
  application.save! if application.valid?

  #-----------------
  # 8th student [offers[5] approved]
  #-----------------
  application = InternshipApplications::WeeklyFramed.new(
    aasm_state: :approved,
    submitted_at: 23.days.ago,
    approved_at: 18.days.ago,
    student: students[7],
    motivation_tmp: 'Très motivé pour ce stage, je vous préviens',
    internship_offer: offers[5]
  )
  application.save! if application.valid?
end

def populate_agreements
  troisieme_applications_offers = InternshipApplications::WeeklyFramed.approved
  agreement_0 = Builders::InternshipAgreementBuilder.new(user: troisieme_applications_offers[0].internship_offer.employer)
                                                    .new_from_application(troisieme_applications_offers[0])
  agreement_0.school_manager_accept_terms = true
  agreement_0.employer_accept_terms = false
  agreement_0.aasm_state = :draft
  agreement_0.save!

  agreement_1 = Builders::InternshipAgreementBuilder.new(user: troisieme_applications_offers[1].internship_offer.employer)
                                                    .new_from_application(troisieme_applications_offers[1])
  agreement_1.school_manager_accept_terms = true
  agreement_1.employer_accept_terms = false
  agreement_1.aasm_state = :started_by_school_manager
  agreement_1.save!

  agreement_2 = Builders::InternshipAgreementBuilder.new(user: troisieme_applications_offers[2].internship_offer.employer)
                                                    .new_from_application(troisieme_applications_offers[2])
  agreement_2.school_manager_accept_terms = false
  agreement_2.employer_accept_terms = true
  agreement_2.aasm_state = :completed_by_employer
  agreement_2.save!
end

call_method_with_metrics_tracking(%i[
                                    populate_applications
                                    populate_agreements
                                  ])
