require "test_helper"

class EmployerActionsMailerTest < ActionMailer::TestCase
  include ::EmailSpamEuristicsAssertions

  # ---------------------------------------------------------------------------
  # pending_application digest — existing behaviour
  # ---------------------------------------------------------------------------
  test "digest_email renders pending_application rows" do
    employer = create(:employer)
    internship_application = create(:weekly_internship_application)

    item = MailActionItem.create!(
      recipient: employer,
      action_name: "new_internship_application",
      action_type: :pending_internship_application,
      urgency_level: :medium,
      stale_at: 5.days.from_now,
      resolved_at: nil,
      deliveries_count: 0,
      max_deliveries_count: 1,
      internship_application: internship_application
    )

    actions = { "pending_internship_application" => [ item ] }

    email = EmployerActionsMailer.employer_digest_email(
      user_id: employer.id,
      actions: actions,
      urgency_levels: %w[ low medium ])
    email.deliver_now

    assert_emails 1
    assert_includes email.to, employer.email
    assert_match internship_application.student.presenter.full_name, email.html_part.body.to_s
  end

  # ---------------------------------------------------------------------------
  # agreement_signed_by_all digest — new behaviour
  # ---------------------------------------------------------------------------
  test "digest_email renders agreement_signed_by_all rows when present" do
    employer = create(:employer)
    internship_agreement = create(:mono_internship_agreement, :signed_by_all)

    item = MailActionItem.create!(
      recipient: employer,
      action_name: "agreement_signed_by_all",
      action_type: :pending_internship_agreement,
      urgency_level: :low,
      stale_at: 30.days.from_now,
      resolved_at: nil,
      deliveries_count: 0,
      max_deliveries_count: 1,
      internship_agreement: internship_agreement
    )

    actions = { "pending_internship_agreement" => [ item ] }

    email = EmployerActionsMailer.employer_digest_email(user_id: employer.id, actions: actions, urgency_levels: [ "low" ])
    email.deliver_now

    assert_emails 1
    assert_includes email.to, employer.email

    html_body = email.html_part.body.to_s
    text_body = email.text_part.body.to_s

    student = internship_agreement.internship_application.student
    assert_match student.presenter.full_name, html_body
    assert_match student.school.name, html_body
    assert_match "Voir la convention", html_body

    assert_match student.presenter.full_name, text_body
    assert_match student.school.name, text_body
    assert_match "Voir la convention", text_body
  end

  test "digest_email does not render agreement_signed_by_all section when rows are empty" do
    employer = create(:employer)
    internship_application = create(:weekly_internship_application)

    item = MailActionItem.create!(
      recipient: employer,
      action_name: "new_internship_application",
      action_type: :pending_internship_application,
      urgency_level: :medium,
      stale_at: 5.days.from_now,
      resolved_at: nil,
      deliveries_count: 0,
      max_deliveries_count: 1,
      internship_application: internship_application
    )

    actions = { "pending_internship_application" => [ item ] }

    email = EmployerActionsMailer.employer_digest_email(user_id: employer.id, actions: actions, urgency_levels: [ "medium" ])
    email.deliver_now

    assert_no_match "Conventions sign", email.html_part.body.to_s
    assert_no_match "Conventions sign", email.text_part.body.to_s
  end

  test "digest_email skips agreement_signed_by_all rows with nil agreement" do
    employer = create(:employer)

    item = MailActionItem.create!(
      recipient: employer,
      action_name: "agreement_signed_by_all",
      action_type: :pending_internship_agreement,
      urgency_level: :low,
      stale_at: 30.days.from_now,
      resolved_at: nil,
      deliveries_count: 0,
      max_deliveries_count: 1,
      internship_agreement_id: nil
    )

    actions = { "pending_internship_agreement" => [ item ] }

    email = EmployerActionsMailer.employer_digest_email(user_id: employer.id, actions: actions, urgency_levels: [ "low" ])
    email.deliver_now

    assert_emails 1
    assert_no_match "Voir la convention", email.html_part.body.to_s
  end

  test "digest_email renders signatures_enabled rows when present" do
    employer = create(:employer)
    internship_agreement = create(:mono_internship_agreement, :validated)

    item = MailActionItem.create!(
      recipient: employer,
      action_name: "signatures_enabled",
      action_type: :pending_internship_agreement,
      urgency_level: :medium,
      stale_at: 30.days.from_now,
      resolved_at: nil,
      deliveries_count: 0,
      max_deliveries_count: 2,
      internship_agreement: internship_agreement
    )

    actions = { "pending_internship_agreement" => [ item ] }

    email = EmployerActionsMailer.employer_digest_email(user_id: employer.id, actions: actions, urgency_levels: [ "medium" ])
    email.deliver_now

    assert_emails 1
    assert_includes email.to, employer.email

    html_body = email.html_part.body.to_s
    text_body = email.text_part.body.to_s

    student = internship_agreement.internship_application.student
    assert_match "Conventions prêtes à être signées", html_body
    assert_match student.presenter.full_name, html_body
    assert_match student.school.name, html_body
    assert_match "Voir la convention", html_body

    assert_match "Conventions prêtes à être signées", text_body
    assert_match student.presenter.full_name, text_body
    assert_match student.school.name, text_body
    assert_match "Voir la convention", text_body
  end

  test "digest_email renders agreement_to_sign rows in 'Conventions à signer' section (F2)" do
    employer = create(:employer)
    internship_agreement = create(:mono_internship_agreement, :signatures_started)
    internship_application = internship_agreement.internship_application

    item = MailActionItem.create!(
      recipient: employer,
      action_name: "agreement_to_sign",
      action_type: :pending_internship_agreement,
      urgency_level: :medium,
      stale_at: 30.days.from_now,
      resolved_at: nil,
      deliveries_count: 0,
      max_deliveries_count: 1,
      internship_application: internship_application,
      internship_agreement: internship_agreement
    )

    actions = { "pending_internship_agreement" => [ item ] }

    email = EmployerActionsMailer.employer_digest_email(user_id: employer.id, actions: actions, urgency_levels: [ "medium" ])
    email.deliver_now

    assert_emails 1
    html_body = email.html_part.body.to_s
    text_body = email.text_part.body.to_s

    assert_match "Conventions de stage à signer", html_body,
                 "la section 'Conventions à signer' doit apparaître dans le mail"
    assert_match internship_application.student.presenter.full_name, html_body
    assert_match "Voir la convention", html_body

    assert_match "Conventions de stage à signer", text_body
    assert_match internship_application.student.presenter.full_name, text_body
    assert_match "Voir la convention", text_body
  end

  test "digest_email renders agreement_to_sign rows when item only has internship_agreement_id (no internship_application_id) — cas élève signe en premier (F2b)" do
    internship_agreement = create(:mono_internship_agreement, :signatures_started)
    employer = internship_agreement.employer
    internship_application = internship_agreement.internship_application

    item = MailActionItem.create!(
      recipient: employer,
      action_name: "agreement_to_sign",
      action_type: :pending_internship_agreement,
      urgency_level: :medium,
      stale_at: 30.days.from_now,
      resolved_at: nil,
      deliveries_count: 0,
      max_deliveries_count: 1,
      internship_application: nil,
      internship_agreement: internship_agreement
    )

    actions = { "pending_internship_agreement" => [ item ] }

    email = EmployerActionsMailer.employer_digest_email(user_id: employer.id, actions: actions, urgency_levels: [ "medium" ])
    email.deliver_now

    assert_emails 1
    html_body = email.html_part.body.to_s
    text_body = email.text_part.body.to_s

    assert_match "Conventions de stage à signer", html_body,
                 "la section doit apparaître même sans internship_application_id sur l'item"
    assert_match internship_application.student.presenter.full_name, html_body
    assert_match "Voir la convention", html_body

    assert_match "Conventions de stage à signer", text_body
    assert_match internship_application.student.presenter.full_name, text_body
    assert_match "Voir la convention", text_body
  end

  test "digest_email renders agreement_signed_by_another rows in 'Conventions signées par un tiers' section" do
    internship_agreement = create(:mono_internship_agreement, :signatures_started)
    employer = internship_agreement.employer
    internship_application = internship_agreement.internship_application

    item = MailActionItem.create!(
      recipient: employer,
      action_name: "agreement_signed_by_another",
      action_type: :pending_internship_agreement,
      urgency_level: :low,
      stale_at: 30.days.from_now,
      resolved_at: nil,
      deliveries_count: 0,
      max_deliveries_count: 1,
      internship_application: nil,
      internship_agreement: internship_agreement
    )

    actions = { "pending_internship_agreement" => [ item ] }

    email = EmployerActionsMailer.employer_digest_email(user_id: employer.id, actions: actions, urgency_levels: [ "low" ])
    email.deliver_now

    assert_emails 1
    html_body = email.html_part.body.to_s
    text_body = email.text_part.body.to_s

    assert_match "Conventions signées par un tiers", html_body
    assert_match internship_application.student.presenter.full_name, html_body
    assert_match internship_application.internship_offer.title, html_body

    assert_match "Conventions signées par un tiers", text_body
    assert_match internship_application.student.presenter.full_name, text_body
  end

  test "digest_email renders new_agreement_to_fill_in rows in agreement section" do
    employer = create(:employer)
    internship_agreement = create(:mono_internship_agreement, :draft)
    internship_application = internship_agreement.internship_application

    item = MailActionItem.create!(
      recipient: employer,
      action_name: "new_agreement_to_fill_in",
      action_type: :pending_internship_agreement,
      urgency_level: :medium,
      stale_at: 30.days.from_now,
      resolved_at: nil,
      deliveries_count: 0,
      max_deliveries_count: 2,
      internship_application: internship_application,
      internship_agreement: internship_agreement
    )

    actions = { "pending_internship_agreement" => [ item ] }

    email = EmployerActionsMailer.employer_digest_email(user_id: employer.id, actions: actions, urgency_levels: [ "medium" ])
    email.deliver_now

    assert_emails 1
    assert_includes email.to, employer.email

    html_body = email.html_part.body.to_s
    text_body = email.text_part.body.to_s

    assert_match "Conventions de stage à compléter", html_body
    assert_match internship_application.student.presenter.full_name, html_body
    assert_match "Remplir la convention", html_body

    assert_match "Conventions de stage à compléter", text_body
    assert_match internship_application.student.presenter.full_name, text_body
    assert_match "Remplir la convention", text_body
  end
end
