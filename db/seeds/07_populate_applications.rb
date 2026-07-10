def populate_applications
  seconde_students   = Users::Student.all.select { |s| s.grade_id == Grade.seconde.id }
  troisieme_students = Users::Student.all.select { |s| s.grade_id == Grade.troisieme.id }

  seconde_offers   = InternshipOffers::WeeklyFramed.all.select { |o| o.grades.include?(Grade.seconde) && o.published? }
  troisieme_offers = InternshipOffers::WeeklyFramed.all.select { |o| o.grades.include?(Grade.troisieme) && o.published? }

  def make_application(klass, student:, offer:, state:, attrs: {})
    app = klass.new(
      {
        aasm_state:   state,
        submitted_at: attrs.fetch(:submitted_at, 10.days.ago),
        student:      student,
        motivation:   'Très motivé pour ce stage',
        internship_offer: offer,
        student_phone: "060606#{(1000..9999).to_a.sample}",
        student_email: student.email,
        weeks: [ offer.weeks.first ]
      }.merge(attrs)
    )
    if app.valid?
      app.save!
    else
      puts "[ERREUR] Application #{state} invalide : #{app.errors.full_messages.join(', ')} (offer #{offer.id})"
    end
    app
  end

  # -----------------------------------------------------------------------
  # submitted — candidature déposée, non lue
  # -----------------------------------------------------------------------
  # 2de
  make_application(InternshipApplications::WeeklyFramed,
    student: seconde_students[0],
    offer:   seconde_offers[0],
    state:   :submitted,
    attrs:   { submitted_at: 3.days.ago })

  # 3ème
  make_application(InternshipApplications::WeeklyFramed,
    student: troisieme_students[0],
    offer:   troisieme_offers[0],
    state:   :submitted,
    attrs:   { submitted_at: 5.days.ago })

  # -----------------------------------------------------------------------
  # read_by_employer — lue par l'employeur, sans suite encore
  # -----------------------------------------------------------------------
  # 2de
  make_application(InternshipApplications::WeeklyFramed,
    student: seconde_students[1],
    offer:   seconde_offers[0],
    state:   :read_by_employer,
    attrs:   { submitted_at: 8.days.ago,
               read_at:      6.days.ago })

  # 3ème
  make_application(InternshipApplications::WeeklyFramed,
    student: troisieme_students[1],
    offer:   troisieme_offers[0],
    state:   :read_by_employer,
    attrs:   { submitted_at: 7.days.ago,
               read_at:      5.days.ago })

  # -----------------------------------------------------------------------
  # validated_by_employer — validée par l'employeur, en attente du chef d'établissement
  # -----------------------------------------------------------------------
  # 2de
  make_application(InternshipApplications::WeeklyFramed,
    student: seconde_students[2],
    offer:   seconde_offers[1],
    state:   :validated_by_employer,
    attrs:   { submitted_at:             12.days.ago,
               read_at:                  10.days.ago,
               validated_by_employer_at:  4.days.ago })

  # 3ème
  make_application(InternshipApplications::WeeklyFramed,
    student: troisieme_students[2],
    offer:   troisieme_offers[1],
    state:   :validated_by_employer,
    attrs:   { submitted_at:             10.days.ago,
               read_at:                   8.days.ago,
               validated_by_employer_at:  3.days.ago })

  # -----------------------------------------------------------------------
  # approved — approuvée par le chef d'établissement
  # (x4 par niveau pour alimenter les 4 états de convention)
  # -----------------------------------------------------------------------
  approved_seconde_offers    = [ seconde_offers[2], seconde_offers[0], seconde_offers[1], seconde_offers[2] ]
  approved_troisieme_offers  = [ troisieme_offers[2], troisieme_offers[0], troisieme_offers[1], troisieme_offers[2] ]
  approved_seconde_students  = seconde_students.values_at(3, 7, 8, 9)
  approved_troisieme_students = troisieme_students.values_at(3, 7, 8, 9)

  approved_seconde_students.each_with_index do |student, i|
    next unless student && approved_seconde_offers[i]
    make_application(InternshipApplications::WeeklyFramed,
      student: student,
      offer:   approved_seconde_offers[i],
      state:   :approved,
      attrs:   { submitted_at:             (20 + i).days.ago,
                 read_at:                  (16 + i).days.ago,
                 validated_by_employer_at:  (10 + i).days.ago,
                 approved_at:               (5 + i).days.ago })
  end

  approved_troisieme_students.each_with_index do |student, i|
    next unless student && approved_troisieme_offers[i]
    make_application(InternshipApplications::WeeklyFramed,
      student: student,
      offer:   approved_troisieme_offers[i],
      state:   :approved,
      attrs:   { submitted_at:             (18 + i).days.ago,
                 read_at:                  (14 + i).days.ago,
                 validated_by_employer_at:   (8 + i).days.ago,
                 approved_at:               (4 + i).days.ago })
  end

  # -----------------------------------------------------------------------
  # rejected — refusée par l'employeur
  # -----------------------------------------------------------------------
  # 2de
  make_application(InternshipApplications::WeeklyFramed,
    student: seconde_students[4],
    offer:   seconde_offers[0],
    state:   :rejected,
    attrs:   { submitted_at: 15.days.ago,
               read_at:      12.days.ago,
               rejected_at:   5.days.ago })

  # 3ème
  make_application(InternshipApplications::WeeklyFramed,
    student: troisieme_students[4],
    offer:   troisieme_offers[0],
    state:   :rejected,
    attrs:   { submitted_at: 14.days.ago,
               read_at:      11.days.ago,
               rejected_at:   6.days.ago })

  # -----------------------------------------------------------------------
  # canceled_by_employer — annulée par l'employeur après approbation
  # -----------------------------------------------------------------------
  # 2de
  make_application(InternshipApplications::WeeklyFramed,
    student: seconde_students[5],
    offer:   seconde_offers[1],
    state:   :canceled_by_employer,
    attrs:   { submitted_at:             25.days.ago,
               read_at:                  22.days.ago,
               validated_by_employer_at: 15.days.ago,
               approved_at:              10.days.ago,
               canceled_at:               3.days.ago })

  # 3ème
  make_application(InternshipApplications::WeeklyFramed,
    student: troisieme_students[5],
    offer:   troisieme_offers[1],
    state:   :canceled_by_employer,
    attrs:   { submitted_at:             22.days.ago,
               read_at:                  19.days.ago,
               validated_by_employer_at: 12.days.ago,
               approved_at:               8.days.ago,
               canceled_at:               2.days.ago })

  # -----------------------------------------------------------------------
  # canceled_by_student — annulée par l'élève
  # -----------------------------------------------------------------------
  # 2de
  make_application(InternshipApplications::WeeklyFramed,
    student: seconde_students[6],
    offer:   seconde_offers[2],
    state:   :canceled_by_student,
    attrs:   { submitted_at:             18.days.ago,
               read_at:                  15.days.ago,
               validated_by_employer_at: 10.days.ago,
               approved_at:               7.days.ago,
               canceled_at:               2.days.ago })

  # 3ème
  make_application(InternshipApplications::WeeklyFramed,
    student: troisieme_students[6],
    offer:   troisieme_offers[2],
    state:   :canceled_by_student,
    attrs:   { submitted_at:             16.days.ago,
               read_at:                  13.days.ago,
               validated_by_employer_at:  9.days.ago,
               approved_at:               6.days.ago,
               canceled_at:               1.day.ago })

  # -----------------------------------------------------------------------
  # canceled_by_student_confirmation — annulation élève en attente de confirmation
  # -----------------------------------------------------------------------
  # 2de
  make_application(InternshipApplications::WeeklyFramed,
    student: seconde_students[0],
    offer:   seconde_offers[3],
    state:   :canceled_by_student_confirmation,
    attrs:   { submitted_at:             20.days.ago,
               read_at:                  17.days.ago,
               validated_by_employer_at: 12.days.ago,
               approved_at:               8.days.ago,
               canceled_at:               1.day.ago })

  # 3ème
  make_application(InternshipApplications::WeeklyFramed,
    student: troisieme_students[0],
    offer:   troisieme_offers[3],
    state:   :canceled_by_student_confirmation,
    attrs:   { submitted_at:             19.days.ago,
               read_at:                  16.days.ago,
               validated_by_employer_at: 11.days.ago,
               approved_at:               7.days.ago,
               canceled_at:               1.day.ago })

  # -----------------------------------------------------------------------
  # restored — candidature restaurée après annulation élève
  # -----------------------------------------------------------------------
  # 2de
  make_application(InternshipApplications::WeeklyFramed,
    student: seconde_students[1],
    offer:   seconde_offers[3],
    state:   :restored,
    attrs:   { submitted_at:             30.days.ago,
               read_at:                  27.days.ago,
               validated_by_employer_at: 20.days.ago,
               approved_at:              15.days.ago,
               canceled_at:              10.days.ago,
               restored_at:               5.days.ago })

  # 3ème
  make_application(InternshipApplications::WeeklyFramed,
    student: troisieme_students[1],
    offer:   troisieme_offers[3],
    state:   :restored,
    attrs:   { submitted_at:             28.days.ago,
               read_at:                  25.days.ago,
               validated_by_employer_at: 18.days.ago,
               approved_at:              14.days.ago,
               canceled_at:               9.days.ago,
               restored_at:               4.days.ago })

  # -----------------------------------------------------------------------
  # expired — expirée automatiquement (délai dépassé côté employeur)
  # -----------------------------------------------------------------------
  # 2de
  make_application(InternshipApplications::WeeklyFramed,
    student: seconde_students[2],
    offer:   seconde_offers[3],
    state:   :expired,
    attrs:   { submitted_at: 45.days.ago,
               read_at:      40.days.ago,
               expired_at:   20.days.ago })

  # 3ème
  make_application(InternshipApplications::WeeklyFramed,
    student: troisieme_students[2],
    offer:   troisieme_offers[3],
    state:   :expired,
    attrs:   { submitted_at: 42.days.ago,
               read_at:      38.days.ago,
               expired_at:   18.days.ago })

  # -----------------------------------------------------------------------
  # expired_by_student — expirée côté élève (délai de réponse dépassé)
  # -----------------------------------------------------------------------
  # 2de
  make_application(InternshipApplications::WeeklyFramed,
    student: seconde_students[3],
    offer:   seconde_offers[4] || seconde_offers[0],
    state:   :expired_by_student,
    attrs:   { submitted_at:             40.days.ago,
               read_at:                  37.days.ago,
               validated_by_employer_at: 30.days.ago,
               expired_at:               15.days.ago })

  # 3ème
  make_application(InternshipApplications::WeeklyFramed,
    student: troisieme_students[3],
    offer:   troisieme_offers[4] || troisieme_offers[0],
    state:   :expired_by_student,
    attrs:   { submitted_at:             38.days.ago,
               read_at:                  35.days.ago,
               validated_by_employer_at: 28.days.ago,
               expired_at:               14.days.ago })

  # -----------------------------------------------------------------------
  # transfered — transférée à un autre employeur
  # -----------------------------------------------------------------------
  # 2de
  make_application(InternshipApplications::WeeklyFramed,
    student: seconde_students[4],
    offer:   seconde_offers[4] || seconde_offers[1],
    state:   :transfered,
    attrs:   { submitted_at:  12.days.ago,
               read_at:        9.days.ago,
               transfered_at:  5.days.ago })

  # 3ème
  make_application(InternshipApplications::WeeklyFramed,
    student: troisieme_students[4],
    offer:   troisieme_offers[4] || troisieme_offers[1],
    state:   :transfered,
    attrs:   { submitted_at:  11.days.ago,
               read_at:        8.days.ago,
               transfered_at:  4.days.ago })
end

call_method_with_metrics_tracking(%i[ populate_applications ])
