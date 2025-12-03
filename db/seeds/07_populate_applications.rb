def populate_applications
  students = Users::Student.all
  offers = InternshipOffers::WeeklyFramed.all
  puts 'every offers receives an application from first stud'
  offers.first(4).each do |offer|
    puts "offer #{offer.id} receives an application from first stud"
    application = InternshipApplications::WeeklyFramed.new(
      aasm_state: :submitted,
      submitted_at: 10.days.ago,
      student: students.first,
      motivation: 'Au taquet',
      internship_offer: offer,
      student_phone: "060606#{(1000..9999).to_a.sample}",
      student_email: 'paul@gmail.com',
      weeks: [offer.weeks.first]
    )
    application.save!
  end
  #-----------------
  # 2nd student [1 approved, 1 canceled_by_employer]
  #-----------------
  # puts 'second offer receive an approval --> second stud'
  # this_offer = offers.first
  # application = InternshipApplications::WeeklyFramed.new(
  #   aasm_state: :canceled_by_employer,
  #   submitted_at: 10.days.ago,
  #   approved_at: 2.days.ago,
  #   student: students.second,
  #   motivation: 'Au taquet',
  #   internship_offer: this_offer,
  #   student_phone: "060606#{(1000..9999).to_a.sample}",
  #   student_email: 'paul@gmail.com',
  #   weeks: [this_offer.weeks.first]
  # )
  # application.save!

  puts 'second stud is canceled by employer of last internship_offer'
  this_offer = offers.second
  application = InternshipApplications::WeeklyFramed.new(
    aasm_state: :approved,
    submitted_at: 10.days.ago,
    approved_at: 3.days.ago,
    canceled_at: 1.day.ago,
    student: students.second,
    motivation: 'Parce que ma société n\'a pas d\'encadrant cette semaine là',
    internship_offer: this_offer,
    student_phone: "060606#{(1000..9999).to_a.sample}",
    student_email: 'paul@gmail.com',
    weeks: [this_offer.weeks.first]
  )
  application.save!

  #-----------------
  # third student [offers.fourth approved, 1 canceled_by_student]
  #-----------------
  this_offer = offers.third
  applications = InternshipApplications::WeeklyFramed.new(
    aasm_state: :approved,
    submitted_at: 10.days.ago,
    approved_at: 2.days.ago,
    student: students.third,
    motivation: 'Au taquet',
    internship_offer: this_offer,
    student_phone: "060606#{(1000..9999).to_a.sample}",
    student_email: 'paul@gmail.com',
    weeks: [this_offer.weeks.first]
  )
  applications.save!

  # puts 'third stud cancels his application to first offer'
  # this_offer = offers.fourth
  # application = InternshipApplications::WeeklyFramed.new(
  #   aasm_state: :canceled_by_student,
  #   submitted_at: 10.days.ago,
  #   approved_at: 2.days.ago,
  #   canceled_at: 1.day.ago,
  #   student: students.third,
  #   motivation: 'Au taquet',
  #   internship_offer: this_offer,
  #   student_phone: "060606#{(1000..9999).to_a.sample}",
  #   student_email: 'paul@gmail.com',
  #   weeks: [this_offer.weeks.first]
  # )
  # application.save!

  #-----------------
  # 4th student [0 approved]
  #-----------------
  this_offer = offers.fourth
  application = InternshipApplications::WeeklyFramed.new(
    aasm_state: :validated_by_employer,
    submitted_at: 10.days.ago,
    approved_at: 2.days.ago,
    student: students.fourth,
    motivation: 'Au taquet',
    internship_offer: this_offer,
    student_phone: "060606#{(1000..9999).to_a.sample}",
    student_email: 'paul@gmail.com',
    weeks: [this_offer.weeks.first]
  )
  application.save!

  this_offer= offers.fifth
  application = InternshipApplications::WeeklyFramed.new(
    aasm_state: :validated_by_employer,
    submitted_at: 9.days.ago,
    validated_by_employer_at: 3.days.ago,
    student: students.fourth,
    motivation: 'Assez moyennement motivé pour ce stage',
    internship_offer: this_offer,
    student_phone: "060606#{(1000..9999).to_a.sample}",
    student_email: 'paul@gmail.com',
    weeks: [this_offer.weeks.first] )
  application.save!

  this_offer = offers[6]
  application = InternshipApplications::WeeklyFramed.new(
    aasm_state: :validated_by_employer,
    submitted_at: 29.days.ago,
    validated_by_employer_at: 23.days.ago,
    student: students.fourth,
    motivation: 'motivé moyennement pour ce stage, je vous préviens',
    internship_offer: this_offer,
    student_phone: "060606#{(1000..9999).to_a.sample}",
    student_email: 'paul@gmail.com',
    weeks: [this_offer.weeks.first] )
  application.save!

  this_offer = offers[0]
  application = InternshipApplications::WeeklyFramed.new(
  aasm_state: :validated_by_employer,
  submitted_at: 29.days.ago,
  student: students.fourth,
  motivation: 'motivé moyennement pour ce stage, je vous préviens',
  student_phone: "060606#{(1000..9999).to_a.sample}",
  student_email: 'paul@gmail.com',
  internship_offer: this_offer,
  weeks: [this_offer.weeks.first] )
  application.save!

  this_offer = offers[5]
  application = InternshipApplications::WeeklyFramed.new(
    aasm_state: :validated_by_employer,
    submitted_at: 29.days.ago,
    validated_by_employer_at: 20.days.ago,
    student: students.fourth,
    motivation: 'Très motivé pour ce stage, je vous préviens',
    student_phone: "060606#{(1000..9999).to_a.sample}",
    student_email: 'paul@gmail.com',
    internship_offer: this_offer,
    weeks: [this_offer.weeks.first] )
  application.save! if application.valid?

  #-----------------
  # 5th student [offers.third approved]
  #-----------------
  this_offer = offer[5]
  application = InternshipApplications::WeeklyFramed.new(
    aasm_state: :approved,
    submitted_at: 29.days.ago,
    validated_by_employer_at: 20.days.ago,
    student: students.troisieme.first,
    motivation: 'Très motivé pour ce stage, je vous préviens',
    student_phone: "060606#{(1000..9999).to_a.sample}",
    student_email: 'paul@gmail.com',
    internship_offer: this_offer,
    weeks: [this_offer.weeks.first] )
  application.save! if application.valid?
  #-----------------
  # 6th student [offers.seventh approved]
  #-----------------
  #-----------------
  # 7th student [offers[4] approved]
  #-----------------
  this_offer = offers[4]
  application = InternshipApplications::WeeklyFramed.new(
    aasm_state: :approved,
    submitted_at: 23.days.ago,
    approved_at: 18.days.ago,
    student: students[6],
    motivation: 'Très motivé pour ce stage, je vous préviens',
    internship_offer: this_offer,
    weeks: [this_offer.weeks.first]
  )
  application.save! if application.valid?

  #-----------------
  # 8th student [Multi[0] approved]
  #-----------------
  this_offer = InternshipOffers::Multi.first
  application = InternshipApplications::WeeklyFramed.new(
    aasm_state: :approved,
    submitted_at: 23.days.ago,
    approved_at: 18.days.ago,
    student: students[7],
    motivation: 'Très motivé pour ce stage, je vous préviens',
    internship_offer: offers[5],
    weeks: [this_offer.weeks.first]
  )
  application.save! if application.valid?

  #-----------------
  #  student [offers[5] approved]
  #-----------------
end

call_method_with_metrics_tracking(%i[ populate_applications ])
