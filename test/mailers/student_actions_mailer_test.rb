require "test_helper"

class StudentActionsMailerTest < ActionMailer::TestCase
  test "student_digest_email renders internship_application_rejected rows" do
    internship_application = create(:weekly_internship_application, :rejected)
    student = internship_application.student

    item = MailActionItem.create!(
      recipient: student,
      action_name: "internship_application_rejected",
      action_type: :pending_internship_application,
      urgency_level: :high,
      stale_at: 5.days.from_now,
      resolved_at: nil,
      deliveries_count: 0,
      max_deliveries_count: 1,
      internship_application: internship_application
    )

    actions = { "pending_internship_application" => [ item ] }

    email = StudentActionsMailer.student_digest_email(
      user_id: student.id,
      actions: actions,
      urgency_levels: [ "high" ]
    )
    email.deliver_now

    assert_emails 1
    assert_includes email.to, student.email

    html_body = email.html_part.body.to_s
    text_body = email.text_part.body.to_s
    offer     = internship_application.internship_offer

    assert_match "Candidatures refusées", html_body
    assert_match offer.title, html_body
    assert_match "Trouver d'autres offres", html_body

    assert_match "Candidatures refusées", text_body
    assert_match offer.title, text_body
    assert_match "Trouver d'autres offres", text_body
  end

  test "student_digest_email renders internship_application_validated_by_employer rows" do
    internship_application = create(:weekly_internship_application, :validated_by_employer)
    student = internship_application.student

    item = MailActionItem.create!(
      recipient: student,
      action_name: "internship_application_validated_by_employer",
      action_type: :pending_internship_application,
      urgency_level: :high,
      stale_at: 5.days.from_now,
      resolved_at: nil,
      deliveries_count: 0,
      max_deliveries_count: 1,
      internship_application: internship_application
    )

    actions = { "pending_internship_application" => [ item ] }

    email = StudentActionsMailer.student_digest_email(
      user_id: student.id,
      actions: actions,
      urgency_levels: [ "high" ]
    )
    email.deliver_now

    assert_emails 1
    assert_includes email.to, student.email

    html_body = email.html_part.body.to_s
    text_body = email.text_part.body.to_s
    offer     = internship_application.internship_offer

    assert_match "validées par l'employeur", html_body
    assert_match offer.title, html_body
    assert_match "Confirmer ma candidature", html_body

    assert_match "validées par l'employeur", text_body
    assert_match offer.title, text_body
    assert_match "Confirmer ma candidature", text_body
  end

  test "student_digest_email renders internship_application_expired rows" do
    internship_application = create(:weekly_internship_application, :expired)
    student = internship_application.student

    item = MailActionItem.create!(
      recipient: student,
      action_name: "internship_application_expired",
      action_type: :pending_internship_application,
      urgency_level: :medium,
      stale_at: 5.days.from_now,
      resolved_at: nil,
      deliveries_count: 0,
      max_deliveries_count: 1,
      internship_application: internship_application
    )

    actions = { "pending_internship_application" => [ item ] }

    email = StudentActionsMailer.student_digest_email(
      user_id: student.id,
      actions: actions,
      urgency_levels: [ "medium" ]
    )
    email.deliver_now

    assert_emails 1
    assert_includes email.to, student.email

    html_body = email.html_part.body.to_s
    text_body = email.text_part.body.to_s
    offer     = internship_application.internship_offer

    assert_match "Candidatures expirées", html_body
    assert_match offer.title, html_body
    assert_match "Trouver d'autres offres", html_body

    assert_match "Candidatures expirées", text_body
    assert_match offer.title, text_body
    assert_match "Trouver d'autres offres", text_body
  end

  test "student_digest_email renders agreement_to_sign rows" do
    internship_agreement = create(:mono_internship_agreement)
    internship_application = internship_agreement.internship_application
    student = internship_application.student

    item = MailActionItem.create!(
      recipient: student,
      action_name: "agreement_to_sign",
      action_type: :pending_internship_agreement,
      urgency_level: :medium,
      stale_at: 5.days.from_now,
      resolved_at: nil,
      deliveries_count: 0,
      max_deliveries_count: 1,
      internship_agreement: internship_agreement
    )

    actions = { "pending_internship_agreement" => [ item ] }

    email = StudentActionsMailer.student_digest_email(
      user_id: student.id,
      actions: actions,
      urgency_levels: [ "medium" ]
    )
    email.deliver_now

    assert_emails 1
    assert_includes email.to, student.email

    html_body = email.html_part.body.to_s
    text_body = email.text_part.body.to_s
    offer     = internship_application.internship_offer

    assert_match "Conventions en attente de votre signature", html_body
    assert_match offer.title, html_body
    assert_match "Voir la convention", html_body

    assert_match "Conventions en attente de votre signature", text_body
    assert_match offer.title, text_body
    assert_match "Voir la convention", text_body
  end

  test "student_digest_email renders agreement_signed_by_all rows" do
    internship_agreement = create(:mono_internship_agreement)
    internship_application = internship_agreement.internship_application
    student = internship_application.student

    item = MailActionItem.create!(
      recipient: student,
      action_name: "agreement_signed_by_all",
      action_type: :pending_internship_agreement,
      urgency_level: :medium,
      stale_at: 5.days.from_now,
      resolved_at: nil,
      deliveries_count: 0,
      max_deliveries_count: 1,
      internship_agreement: internship_agreement
    )

    actions = { "pending_internship_agreement" => [ item ] }

    email = StudentActionsMailer.student_digest_email(
      user_id: student.id,
      actions: actions,
      urgency_levels: [ "medium" ]
    )
    email.deliver_now

    assert_emails 1
    assert_includes email.to, student.email

    html_body = email.html_part.body.to_s
    text_body = email.text_part.body.to_s
    offer     = internship_application.internship_offer

    assert_match "Conventions signées par toutes les parties", html_body
    assert_match offer.title, html_body
    assert_match "Voir la convention", html_body

    assert_match "Conventions signées par toutes les parties", text_body
    assert_match offer.title, text_body
    assert_match "Voir la convention", text_body
  end
end
