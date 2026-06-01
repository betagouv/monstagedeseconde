# frozen_string_literal: true

require 'test_helper'

class StudentMailerTest < ActionMailer::TestCase
  include EmailSpamEuristicsAssertions

  test 'email sent when internship application is approved' do
    internship_application = create(:weekly_internship_application)
    email = StudentMailer.internship_application_approved_email(internship_application: internship_application)

    email.deliver_now
    assert_emails 1
    assert_equal EmailUtils.from, email.from.first
    assert_equal [internship_application.student.email], email.to
    refute_email_spammyness(email)
  end

  test 'email sent when internship application is rejected' do
    internship_application = create(:weekly_internship_application)

    email = StudentMailer.internship_application_rejected_email(internship_application: internship_application)

    email.deliver_now
    assert_emails 1

    assert_equal EmailUtils.from, email.from.first
    assert_equal [internship_application.student.email], email.to
    refute_email_spammyness(email)
  end

  test 'rejected email neutralizes HTML in rejected_message (XSS regression)' do
    internship_application = create(
      :weekly_internship_application,
      rejected_message: %(<script>alert("xss")</script>)
    )

    email = StudentMailer.internship_application_rejected_email(internship_application: internship_application)
    html_body = email.html_part.body.to_s

    refute_includes html_body, '<script'
    refute_includes html_body, 'alert("xss")</script>'
  end

  test 'email sent when internship application is canceled by employer' do
    internship_application = create(:weekly_internship_application)

    email = StudentMailer.internship_application_canceled_by_employer_email(
      internship_application: internship_application
    )

    email.deliver_now
    assert_emails 1

    assert_equal EmailUtils.from, email.from.first
    assert_equal [internship_application.student.email], email.to
    refute_email_spammyness(email)
  end

  test 'canceled_by_employer email neutralizes HTML in canceled_by_employer_message (XSS regression)' do
    internship_application = create(
      :weekly_internship_application,
      canceled_by_employer_message: %(<script>alert("xss")</script>)
    )

    email = StudentMailer.internship_application_canceled_by_employer_email(
      internship_application: internship_application
    )
    html_body = email.html_part.body.to_s

    refute_includes html_body, '<script'
    refute_includes html_body, 'alert("xss")</script>'
  end

  test 'email sent when internship application is validated by employer' do
    internship_application = create(
      :weekly_internship_application,
      :validated_by_employer,
      validated_by_employer_at: 2.days.ago)

    email = StudentMailer.internship_application_validated_by_employer_email(
      internship_application: internship_application
    )

    email.deliver_now
    assert_emails 1

    assert_equal EmailUtils.from, email.from.first
    assert_equal [internship_application.student.email], email.to
    refute_email_spammyness(email)
  end

  test 'email sent when internship application is validated by employer as a reminder' do
    internship_application = create(
      :weekly_internship_application,
      :validated_by_employer,
      validated_by_employer_at: 2.days.ago)

    email = StudentMailer.internship_application_validated_by_employer_reminder_email(
      applications_to_notify: [internship_application]
    )

    email.deliver_now
    assert_emails 1

    assert_equal EmailUtils.from, email.from.first
    assert_equal [internship_application.student.email], email.to
    refute_email_spammyness(email)
  end
end
