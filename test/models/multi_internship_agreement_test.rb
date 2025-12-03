require "test_helper"

class MultiInternshipAgreementTest < ActiveSupport::TestCase

  test 'factory is valid' do
    multi_internship_agreement = build(
      :multi_internship_agreement,
      enforce_school_manager_validations: true
      )
    
      multi_internship_agreement.valid?
      puts ''
      require 'pretty_console'
      PrettyConsole.puts_in_yellow_loudly('==+==+==+==+' *4)
      PrettyConsole.puts_in_cyan_loudly "multi_internship_agreement.errors.full_messages : #{multi_internship_agreement.errors.full_messages}"
      PrettyConsole.puts_in_yellow_loudly('==+==+==+==+' *4)
      puts ''
      assert multi_internship_agreement.valid?
    
  end

  test 'should belong to internship_application' do
    association = InternshipAgreements::MultiInternshipAgreement.reflect_on_association(:internship_application)
    assert_equal :belongs_to, association.macro
  end

  test 'should belong to user with coordinator_id as foreign key' do
    association = InternshipAgreements::MultiInternshipAgreement.reflect_on_association(:coordinator)
    assert_equal :belongs_to, association.macro
    assert_equal "User", association.options[:class_name]
  end

  test 'is invalid without internship_application' do
    multi_internship_agreement = build(
      :multi_internship_agreement,
      internship_application_id: nil
      )
    assert_not multi_internship_agreement.valid?
    assert_includes multi_internship_agreement.errors[:internship_application], "doit exister"
  end

  test 'is invalid without user (coordinator_id)' do
    multi_internship_agreement = build(
      :multi_internship_agreement,
      coordinator: nil, access_token: "shor",
      student_full_name:'f',
      enforce_school_manager_validations: true
    )
    refute multi_internship_agreement.valid?
    assert_includes multi_internship_agreement.errors[:coordinator], "doit exister"
    assert_includes multi_internship_agreement.errors[:access_token], "ne fait pas la bonne longueur (doit comporter 20 caractères)"
    assert_includes multi_internship_agreement.errors[:student_full_name], "est trop court (au moins 5 caractères)"
  end

  test 'is invalid without organisation_representative_role' do
    multi_internship_agreement = build(
      :multi_internship_agreement,
      enforce_school_manager_validations: true,
      organisation_representative_role: nil
      )
    refute multi_internship_agreement.valid?
    assert_includes multi_internship_agreement.errors[:organisation_representative_role], "doit être rempli(e)"
  end

  test 'is invalid if organisation_representative_role is too long' do
    multi_internship_agreement = build(
      :multi_internship_agreement,
      organisation_representative_role: 'a' * 151,
      enforce_school_manager_validations: true)
    refute multi_internship_agreement.valid?
    assert_includes multi_internship_agreement.errors[:organisation_representative_role], "est trop long (pas plus de 150 caractères)"
  end

  test 'is invalid without student_address' do
    multi_internship_agreement = build(
      :multi_internship_agreement,
      enforce_school_manager_validations: true,
      student_address: nil
      )
    refute multi_internship_agreement.valid?
    assert_includes multi_internship_agreement.errors[:student_address], "doit être rempli(e)"
  end

  test 'is invalid if student_address is too long' do
    multi_internship_agreement = build(
      :multi_internship_agreement,
      enforce_school_manager_validations: true,
      student_address: 'a' * 171
      )
    refute multi_internship_agreement.valid?
    assert_includes multi_internship_agreement.errors[:student_address], "est trop long (pas plus de 170 caractères)"
  end

  test 'is invalid without school_representative_phone' do
    multi_internship_agreement = build(
      :multi_internship_agreement,
      enforce_school_manager_validations: true,
      school_representative_phone: nil
      )
    refute multi_internship_agreement.valid?
    assert_includes multi_internship_agreement.errors[:school_representative_phone], "Veuillez saisir le numéro de téléphone du représentant de l'établissement scolaire"
  end

  test 'is invalid if school_representative_phone is too long' do
    multi_internship_agreement = build(
      :multi_internship_agreement,
      school_representative_phone: '1' * 21,
      enforce_school_manager_validations: true)
    refute multi_internship_agreement.valid?
    assert_includes multi_internship_agreement.errors[:school_representative_phone], "est trop long (pas plus de 20 caractères)"
  end

  test 'is invalid if student_full_name is too short or too long' do
    short = build(
      :multi_internship_agreement,
      student_full_name: 'abcd',
      enforce_school_manager_validations: true
      )
    long = build(
      :multi_internship_agreement,
      student_full_name: 'a' * 101,
      enforce_school_manager_validations: true
      )
    refute short.valid?
    refute long.valid?
    assert_includes short.errors[:student_full_name], "est trop court (au moins 5 caractères)"
    assert_includes long.errors[:student_full_name], "est trop long (pas plus de 100 caractères)"
  end

  test 'is invalid without student_legal_representative_email' do
    multi_internship_agreement = build(
      :multi_internship_agreement,
      enforce_school_manager_validations: true,
      student_legal_representative_email: nil
      )
    refute multi_internship_agreement.valid?
    assert_includes multi_internship_agreement.errors[:student_legal_representative_email], "doit être rempli(e)"
  end

  test 'is invalid if student_legal_representative_email is too long' do
    multi_internship_agreement = build(
      :multi_internship_agreement,
      enforce_school_manager_validations: true,
      student_legal_representative_email: 'a' * 101
      )
    refute multi_internship_agreement.valid?
    assert_includes multi_internship_agreement.errors[:student_legal_representative_email], "est trop long (pas plus de 100 caractères)"
  end

  test 'is invalid without student_legal_representative_full_name' do
    multi_internship_agreement = build(
      :multi_internship_agreement,
      student_legal_representative_full_name: nil,
      enforce_school_manager_validations: true
      )
    refute multi_internship_agreement.valid?
    assert_includes multi_internship_agreement.errors[:student_legal_representative_full_name], "doit être rempli(e)"
  end

  test 'is invalid if student_legal_representative_full_name is too long' do
    multi_internship_agreement = build(
      :multi_internship_agreement,
      enforce_school_manager_validations: true,
      student_legal_representative_full_name: 'a' * 101
      )
    refute multi_internship_agreement.valid?
    assert_includes multi_internship_agreement.errors[:student_legal_representative_full_name], "est trop long (pas plus de 100 caractères)"
  end

  test 'is invalid without student_legal_representative_phone' do
    multi_internship_agreement = build(
      :multi_internship_agreement,
      enforce_school_manager_validations: true,
      student_legal_representative_phone: nil)
    refute multi_internship_agreement.valid?
    assert_includes multi_internship_agreement.errors[:student_legal_representative_phone], "doit être rempli(e)"
  end

  test 'is invalid if student_legal_representative_phone is too long' do
    multi_internship_agreement = build(
      :multi_internship_agreement,
      enforce_school_manager_validations: true,
      student_legal_representative_phone: '1' * 41)
    refute multi_internship_agreement.valid?
    assert_includes multi_internship_agreement.errors[:student_legal_representative_phone], "est trop long (pas plus de 20 caractères)"
  end

  test 'is invalid without school_representative_email' do
    multi_internship_agreement = build(
      :multi_internship_agreement,
      school_representative_email: nil,
      enforce_school_manager_validations: true)
    refute multi_internship_agreement.valid?
    assert_equal ["Veuillez saisir le courriel du représentant de l'établissement scolaire", "est trop court (au moins 5 caractères)"],
                 multi_internship_agreement.errors[:school_representative_email]
  end

  test 'is invalid if school_representative_email is too long' do
    multi_internship_agreement = build(
      :multi_internship_agreement,
      enforce_school_manager_validations: true,
      school_representative_email: 'a' * 101)
    multi_internship_agreement.enforce_school_manager_validations = true
    refute multi_internship_agreement.valid?
    assert_includes multi_internship_agreement.errors[:school_representative_email], "est trop long (pas plus de 100 caractères)"
  end

  test 'is invalid without student_birth_date' do
    multi_internship_agreement = build(
      :multi_internship_agreement,
      enforce_school_manager_validations: true,
      student_birth_date: nil)
    refute multi_internship_agreement.valid?
    assert_includes multi_internship_agreement.errors[:student_birth_date], "doit être rempli(e)"
  end

  test 'is invalid without access_token' do
    multi_internship_agreement = build(
      :multi_internship_agreement,
      enforce_school_manager_validations: true,
      access_token: nil)
    refute multi_internship_agreement.valid?
    assert_includes multi_internship_agreement.errors[:access_token], "doit être rempli(e)"
  end

  test 'is invalid if access_token is not 16 chars' do
    multi_internship_agreement = build(
      :multi_internship_agreement,
      enforce_school_manager_validations: true,
      access_token: 'short')
    refute multi_internship_agreement.valid?
    assert_includes multi_internship_agreement.errors[:access_token], "ne fait pas la bonne longueur (doit comporter 20 caractères)"
  end

  test 'is invalid without activity_scope' do
    multi_internship_agreement = build(
      :multi_internship_agreement,
      enforce_school_manager_validations: true,
      activity_scope: nil)
    refute multi_internship_agreement.valid?
    assert_includes multi_internship_agreement.errors[:activity_scope], "doit être rempli(e)"
  end

  test 'is invalid if activity_scope is too long' do
    multi_internship_agreement = build(
      :multi_internship_agreement,
      enforce_school_manager_validations: true,
      activity_scope: 'a' * 1501)
    refute multi_internship_agreement.valid?
    assert_includes multi_internship_agreement.errors[:activity_scope], "est trop long (pas plus de 1500 caractères)"
  end

  test 'is invalid if both daily_hours and weekly_hours are blank' do
    multi_internship_agreement = build(
      :multi_internship_agreement,
      enforce_school_manager_validations: true,
      daily_hours: nil, weekly_hours: nil)
    refute multi_internship_agreement.valid?
    assert_includes multi_internship_agreement.errors[:base], "Vous devez fournir soit les heures hebdomadaires, soit les heures journalières."
  end

  test 'is valid if daily_hours is present and weekly_hours is blank' do
    multi_internship_agreement = build(
      :multi_internship_agreement,
      daily_hours: "09:00-17:00",
      weekly_hours: nil)
    assert multi_internship_agreement.valid?
  end

  test 'is valid if weekly_hours is present and daily_hours is blank' do
    multi_internship_agreement = build(
      :multi_internship_agreement,
      daily_hours: nil, weekly_hours: ["35"])
    assert multi_internship_agreement.valid?
  end
end
