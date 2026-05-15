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
end
