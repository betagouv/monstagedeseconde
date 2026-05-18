require "test_helper"

class SchoolManagementActionsMailerTest < ActionMailer::TestCase
  test "school_management_digest_email renders internship_agreement_completed_by_employer rows" do
    internship_agreement = create(:mono_internship_agreement, :completed_by_employer)
    school = internship_agreement.internship_application.student.school
    school_representative = school.management_representative || create(:school_manager, school: school)

    item = MailActionItem.create!(
      recipient: school_representative,
      action_name: "internship_agreement_completed_by_employer",
      action_type: :pending_internship_agreement,
      urgency_level: :medium,
      stale_at: 5.days.from_now,
      resolved_at: nil,
      deliveries_count: 0,
      max_deliveries_count: 1,
      internship_agreement: internship_agreement
    )

    actions = { "pending_internship_agreement" => [ item ] }

    email = SchoolManagementActionsMailer.school_management_digest_email(
      user_id: school_representative.id,
      actions: actions,
      urgency_levels: [ "medium" ]
    )
    email.deliver_now

    assert_emails 1
    assert_includes email.to, school_representative.email

    html_body = email.html_part.body.to_s
    text_body = email.text_part.body.to_s

    student = internship_agreement.internship_application.student
    offer = internship_agreement.internship_application.internship_offer

    assert_match "Conventions à compléter", html_body
    assert_match student.presenter.full_name, html_body
    assert_match offer.title, html_body
    assert_match "Editer la convention", html_body

    assert_match "Conventions à compléter", text_body
    assert_match student.presenter.full_name, text_body
    assert_match offer.title, text_body
    assert_match "Editer la convention", text_body
  end

  test "school_management_digest_email renders agreement_signed_by_all rows" do
    internship_agreement = create(:mono_internship_agreement, :signed_by_all)
    school = internship_agreement.internship_application.student.school
    school_representative = school.management_representative || create(:school_manager, school: school)

    item = MailActionItem.create!(
      recipient: school_representative,
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

    email = SchoolManagementActionsMailer.school_management_digest_email(
      user_id: school_representative.id,
      actions: actions,
      urgency_levels: [ "medium" ]
    )
    email.deliver_now

    assert_emails 1
    assert_includes email.to, school_representative.email

    html_body = email.html_part.body.to_s
    text_body = email.text_part.body.to_s

    student = internship_agreement.internship_application.student
    offer = internship_agreement.internship_application.internship_offer

    assert_match "Conventions signées par toutes les parties", html_body
    assert_match student.presenter.full_name, html_body
    assert_match offer.title, html_body
    assert_match "Voir la convention signée", html_body

    assert_match "Conventions signées par toutes les parties", text_body
    assert_match student.presenter.full_name, text_body
    assert_match offer.title, text_body
    assert_match "Voir la convention signée", text_body
  end
end
