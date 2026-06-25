def populate_agreements
  def make_agreement(application, state:)
    employer = application.internship_offer.employer
    agreement = Builders::InternshipAgreementBuilder.new(user: employer)
                                                    .new_from_application(application)
    agreement.skip_notifications_when_system_creation = true
    agreement.aasm_state = state
    if agreement.valid?
      agreement.save!
    else
      puts "[ERREUR] Convention #{state} invalide : #{agreement.errors.full_messages.join(', ')}"
      return nil
    end
    agreement
  end

  def add_signature(agreement, role:, user:, date: 2.days.ago)
    sig = Signature.new(
      internship_agreement: agreement,
      signatory_role:       role,
      signatory_ip:         '127.0.0.1',
      signature_date:       date,
      user_id:              user.id
    )
    if sig.valid?
      sig.save!
    else
      puts "[ERREUR] Signature #{role} invalide : #{sig.errors.full_messages.join(', ')}"
    end
    sig
  end

  seconde_approved   = InternshipApplications::WeeklyFramed.seconde.approved.to_a
  troisieme_approved = InternshipApplications::WeeklyFramed.troisieme.approved.to_a

  if seconde_approved.size < 4 || troisieme_approved.size < 4
    puts "[AVERTISSEMENT] Pas assez de candidatures approuvées pour couvrir tous les états de convention."
    puts "  2de approuvées : #{seconde_approved.size}, 3ème approuvées : #{troisieme_approved.size}"
  end

  # -----------------------------------------------------------------------
  # draft — convention créée, aucune action encore
  # -----------------------------------------------------------------------
  # 3ème
  make_agreement(troisieme_approved[0], state: :draft)
  # 2de
  make_agreement(seconde_approved[0], state: :draft)

  # -----------------------------------------------------------------------
  # started_by_employer — employeur a commencé à remplir
  # -----------------------------------------------------------------------
  # 3ème
  make_agreement(troisieme_approved[0], state: :started_by_employer)
  # 2de
  make_agreement(seconde_approved[0], state: :started_by_employer)

  # -----------------------------------------------------------------------
  # completed_by_employer — employeur a terminé, en attente du chef d'établissement
  # -----------------------------------------------------------------------
  # 3ème
  make_agreement(troisieme_approved[1], state: :completed_by_employer)
  # 2de
  make_agreement(seconde_approved[1], state: :completed_by_employer)

  # -----------------------------------------------------------------------
  # started_by_school_manager — chef d'établissement a commencé à remplir
  # -----------------------------------------------------------------------
  # 3ème
  make_agreement(troisieme_approved[1], state: :started_by_school_manager)
  # 2de
  make_agreement(seconde_approved[1], state: :started_by_school_manager)

  # -----------------------------------------------------------------------
  # validated — convention finalisée, prête à être signée
  # -----------------------------------------------------------------------
  # 3ème
  make_agreement(troisieme_approved[2], state: :validated)
  # 2de
  make_agreement(seconde_approved[2], state: :validated)

  # -----------------------------------------------------------------------
  # signatures_started — convention en cours de signature (aucune signature créée)
  # -----------------------------------------------------------------------
  # 3ème
  make_agreement(troisieme_approved[2], state: :signatures_started)
  # 2de
  make_agreement(seconde_approved[2], state: :signatures_started)

  # -----------------------------------------------------------------------
  # signed_by_all — élève et représentant légal ont signé
  # -----------------------------------------------------------------------
  # 3ème
  agreement_all_3 = make_agreement(troisieme_approved[3], state: :signatures_started)
  if agreement_all_3
    student_3 = troisieme_approved[3].student
    add_signature(agreement_all_3,
      role: 'student',
      user: student_3,
      date: 3.days.ago)
    add_signature(agreement_all_3,
      role: 'student_legal_representative',
      user: student_3,
      date: 2.days.ago)
  end

  # 2de
  agreement_all_2 = make_agreement(seconde_approved[3], state: :signatures_started)
  if agreement_all_2
    student_2 = seconde_approved[3].student
    add_signature(agreement_all_2,
      role: 'student',
      user: student_2,
      date: 3.days.ago)
    add_signature(agreement_all_2,
      role: 'student_legal_representative',
      user: student_2,
      date: 2.days.ago)
  end
end

call_method_with_metrics_tracking(%i[ populate_agreements ])
