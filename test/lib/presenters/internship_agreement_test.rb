# frozen_string_literal: true

require 'test_helper'

module Presenters
  class InternshipAgreementTest < ActiveSupport::TestCase
    # Critère d'acceptation 1 :
    # Convention signée par élève + SchoolManagement → statut signatures_started
    # → l'employeur voit un libellé "En attente de votre signature."
    test 'statut signatures_started : employeur voit libellé en attente de signature quand seuls élève et équipe pédagogique ont signé' do
      school   = create(:school, :with_school_manager)
      student  = create(:student, school:)
      employer = create(:employer)
      internship_application = create(:weekly_internship_application, student:)
      internship_agreement   = create(:mono_internship_agreement,
                                      internship_application:,
                                      aasm_state: 'signatures_started')

      school_manager = school.school_manager
      create(:signature, :school_manager,
             internship_agreement:,
             user_id: school_manager.id)
      create(:signature, :student,
             internship_agreement:,
             user_id: student.id)

      presenter = Presenters::InternshipAgreement.new(internship_agreement, employer)
      assert_includes presenter.inline_status_label,
                      'En attente de votre signature.',
                      "L'employeur devrait voir 'En attente de votre signature.'"
    end

    # Critère d'acceptation 2 :
    # Convention signée par élève + SchoolManagement → statut signatures_started
    # → un autre membre SchoolManagement (other) qui n'a pas signé voit "En attente de votre signature"
    # (car l'équipe pédagogique compte comme une seule signature, donc l'other ne peut pas signer)
    test 'statut signatures_started : membre SchoolManagement non signataire voit libellé en attente de votre signature' do
      school  = create(:school, :with_school_manager)
      student = create(:student, school:)
      other   = create(:other, school:)
      internship_application = create(:weekly_internship_application, student:)
      internship_agreement   = create(:mono_internship_agreement,
                                      internship_application:,
                                      aasm_state: 'signatures_started')

      create(:signature, :student,
             internship_agreement:,
             user_id: student.id)

      presenter = Presenters::InternshipAgreement.new(internship_agreement, other)
      assert_includes presenter.inline_status_label,
                      'En attente de votre signature.',
                      "Un 'other' non signataire devrait voir En attente de votre signature."
    end

    # Critère d'acceptation 3 :
    # Convention signée uniquement par l'élève → il reste plusieurs signataires
    # → school_manager voit "Convention partiellement signée. En attente de votre signature."
    test 'statut signatures_started : school_manager non signataire voit libellé en attente de votre signature' do
      school         = create(:school, :with_school_manager)
      student        = create(:student, school:)
      school_manager = school.school_manager
      internship_application = create(:weekly_internship_application, student:)
      internship_agreement   = create(:mono_internship_agreement,
                                      internship_application:,
                                      aasm_state: 'signatures_started')

      create(:signature, :student,
             internship_agreement:,
             user_id: student.id)

      presenter = Presenters::InternshipAgreement.new(internship_agreement, school_manager)
      assert_includes presenter.inline_status_label,
                      'En attente de votre signature.',
                      'Le school_manager non signataire devrait voir En attente de votre signature.'
    end

    # Critère d'acceptation 4 :
    # Il ne reste plus qu'un signataire (l'employeur) → le libellé le mentionne
    test 'statut signatures_started : quand il ne reste que l employeur à signer le libellé le mentionne' do
      school         = create(:school, :with_school_manager)
      student        = create(:student, school:)
      school_manager = school.school_manager
      internship_application = create(:weekly_internship_application, student:)
      internship_agreement   = create(:mono_internship_agreement,
                                      internship_application:,
                                      aasm_state: 'signatures_started')

      create(:signature, :school_manager, internship_agreement:, user_id: school_manager.id)
      create(:signature, :student,        internship_agreement:, user_id: student.id)
      create(:signature, :student_legal_representative, internship_agreement:, user_id: student.id)

      presenter = Presenters::InternshipAgreement.new(internship_agreement, school_manager)
      assert_includes presenter.inline_status_label,
                      "représentant de l'entreprise",
                      "Quand seul l'employeur manque, le libellé devrait le mentionner"
    end

    # Ability : un membre SchoolManagement non school_manager peut signer
    test 'ability : un other peut signer une convention en signatures_started si personne de l equipe n a signé' do
      school  = create(:school, :with_school_manager)
      student = create(:student, school:)
      other   = create(:other, school:)
      internship_application = create(:weekly_internship_application, student:)
      internship_agreement   = create(:mono_internship_agreement,
                                      internship_application:,
                                      aasm_state: 'signatures_started')

      ability = Ability.new(other)
      assert ability.can?(:sign_internship_agreements, internship_agreement),
             "Un 'other' devrait pouvoir signer une convention en signatures_started"
    end

    # Ability : un other ne peut plus signer si l'équipe pédagogique a déjà signé
    test 'ability : un other ne peut plus signer si l equipe pédagogique a déjà signé' do
      school         = create(:school, :with_school_manager)
      student        = create(:student, school:)
      other          = create(:other, school:)
      school_manager = school.school_manager
      internship_application = create(:weekly_internship_application, student:)
      internship_agreement   = create(:mono_internship_agreement,
                                      internship_application:,
                                      aasm_state: 'signatures_started')

      create(:signature, :school_manager, internship_agreement:, user_id: school_manager.id)

      ability = Ability.new(other)
      refute ability.can?(:sign_internship_agreements, internship_agreement),
             "Un 'other' ne devrait pas pouvoir signer si le school_manager a déjà signé"
    end
  end
end
