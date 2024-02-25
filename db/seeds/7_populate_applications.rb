def populate_applications
  students = Users::Student.all
  offers = InternshipOffers::WeeklyFramed.all
  puts "every 3e generale offers receives an application from first 3e generale stud"
  offers.first(4).each do |offer|
    if offer.id.to_i.even?
      InternshipApplications::WeeklyFramed.create!(
        aasm_state: :submitted,
        submitted_at: 10.days.ago,
        student: students.first,
        motivation: 'Au taquet',
        internship_offer: offer,
        student_phone: "060606#{(1000..9999).to_a.sample}",
        student_email: 'paul@gmail.com'
      )
    else
      InternshipApplications::WeeklyFramed.create!(
        aasm_state: :drafted,
        submitted_at: 10.days.ago,
        student: students.first,
        motivation: 'Au taquet',
        internship_offer: offer,
        student_phone: "060606#{(1000..9999).to_a.sample}",
        student_email: 'paul@gmail.com'
      )
    end
  end
  #-----------------
  # 2nd student [1 approved, 1 canceled_by_employer]
  #-----------------
  puts "second 3e generale offer receive an approval --> second 3e generale stud"
  InternshipApplications::WeeklyFramed.create!(
    aasm_state: :approved,
    submitted_at: 10.days.ago,
    approved_at: 2.days.ago,
    student: students.second,
    motivation: 'Au taquet',
    internship_offer: offers.first,
    student_phone: "060606#{(1000..9999).to_a.sample}",
    student_email: 'paul@gmail.com'
  )

  puts  "second 3e generale stud is canceled by employer of last internship_offer"
  InternshipApplications::WeeklyFramed.create!(
    aasm_state: :canceled_by_employer,
    submitted_at: 10.days.ago,
    approved_at: 3.days.ago,
    canceled_at: 1.day.ago,
    student: students.second,
    motivation: 'Parce que ma société n\'a pas d\'encadrant cette semaine là',
    internship_offer: offers.second,
    student_phone: "060606#{(1000..9999).to_a.sample}",
    student_email: 'paul@gmail.com'
  )
  #-----------------
  # third student [offers.fourth approved, 1 canceled_by_student]
  #-----------------
  InternshipApplications::WeeklyFramed.create!(
    aasm_state: :approved,
    submitted_at: 10.days.ago,
    approved_at: 2.days.ago,
    student: students.third,
    motivation: 'Au taquet',
    internship_offer: offers.third,
    student_phone: "060606#{(1000..9999).to_a.sample}",
    student_email: 'paul@gmail.com'
  )
  puts  "third 3e generale stud cancels his application to first offer"
  InternshipApplications::WeeklyFramed.create!(
    aasm_state: :canceled_by_student,
    submitted_at: 10.days.ago,
    approved_at: 2.days.ago,
    canceled_at: 1.day.ago,
    student: students.third,
    motivation: 'Au taquet',
    internship_offer: offers.fourth,
    student_phone: "060606#{(1000..9999).to_a.sample}",
    student_email: 'paul@gmail.com'
  )
  #-----------------
  # 4th student [0 approved]
  #-----------------
  InternshipApplications::WeeklyFramed.create!(
    aasm_state: :validated_by_employer,
    submitted_at: 10.days.ago,
    approved_at: 2.days.ago,
    student: students.fourth,
    motivation: 'Au taquet',
    internship_offer: offers.fourth,
    student_phone: "060606#{(1000..9999).to_a.sample}",
    student_email: 'paul@gmail.com'
  )
  InternshipApplications::WeeklyFramed.create!(
    aasm_state: :validated_by_employer,
    submitted_at: 9.days.ago,
    validated_by_employer_at: 3.days.ago,
    student: students.fourth,
    motivation: 'Assez moyennement motivé pour ce stage',
    internship_offer: offers.fifth,
    student_phone: "060606#{(1000..9999).to_a.sample}",
    student_email: 'paul@gmail.com'
  )
  InternshipApplications::WeeklyFramed.create!(
    aasm_state: :validated_by_employer,
    submitted_at: 29.days.ago,
    validated_by_employer_at: 23.days.ago,
    student: students.fourth,
    motivation: 'motivé moyennement pour ce stage, je vous préviens',
    internship_offer: offers[6],
    student_phone: "060606#{(1000..9999).to_a.sample}",
    student_email: 'paul@gmail.com'
  )
  InternshipApplications::WeeklyFramed.create!(
    aasm_state: :examined,
    submitted_at: 29.days.ago,
    examined_at: 23.days.ago,
    student: students.fourth,
    motivation: 'motivé moyennement pour ce stage, je vous préviens',
    internship_offer: offers[0],
  )
  InternshipApplications::WeeklyFramed.create!(
    aasm_state: :validated_by_employer,
    submitted_at: 29.days.ago,
    examined_at: 23.days.ago,
    validated_by_employer_at: 20.days.ago,
    student: students.fourth,
    motivation: 'Très motivé pour ce stage, je vous préviens',
    internship_offer: offers[5],
  )
  #-----------------
  # 5th student [offers.third approved]
  #-----------------
  #-----------------
  # 6th student [offers.seventh approved]
  #-----------------
  #-----------------
  # 7th student [offers[4] approved]
  #-----------------
   InternshipApplications::WeeklyFramed.create!(
    aasm_state: :approved,
    submitted_at: 23.days.ago,
    examined_at: 21.days.ago,
    approved_at: 18.days.ago,
    student: students[6],
    motivation: 'Très motivé pour ce stage, je vous préviens',
    internship_offer: offers[4],
  )
  #-----------------
  # 8th student [offers[5] approved]
  #-----------------
   InternshipApplications::WeeklyFramed.create!(
    aasm_state: :approved,
    submitted_at: 23.days.ago,
    examined_at: 21.days.ago,
    approved_at: 18.days.ago,
    student: students[7],
    motivation: 'Très motivé pour ce stage, je vous préviens',
    internship_offer: offers[5],
  )
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

  agreement_3 = Builders::InternshipAgreementBuilder.new(user: troisieme_applications_offers[3].internship_offer.employer)
                                                    .new_from_application(troisieme_applications_offers[3])
  agreement_3.school_manager_accept_terms = true
  agreement_3.employer_accept_terms = true
  agreement_3.aasm_state = :validated
  agreement_3.save!

end

call_method_with_metrics_tracking([
  :populate_applications,
  :populate_agreements
])