require 'test_helper'

class GodMailerTest < ActionMailer::TestCase
  include EmailSpamEuristicsAssertions

  test '.weekly_kpis_email sends email to recipient' do
    email = GodMailer.weekly_kpis_email
    email.deliver_now
    assert_emails 1
    assert_equal [EmailUtils.from], email.from
    assert_equal [ENV['TEAM_EMAIL']], email.to
    refute_email_spammyness(email)
  end

  test 'notify_others_signatures_started_email sends email to recipient' do
    internship_agreement = create(:internship_agreement)
    signature = create(:signature, :school_manager, internship_agreement: internship_agreement)
    email = GodMailer.notify_others_signatures_started_email(
      internship_agreement: internship_agreement,
      missing_signatures_recipients: internship_agreement.missing_signatures_recipients,
      last_signature: signature
      )
    email.deliver_now
    assert_emails 1
    assert_equal [EmailUtils.from], email.from
    expected_recipients = internship_agreement.internship_application.filtered_notification_emails + [ internship_agreement.internship_application.student.email]
    assert_equal expected_recipients.sort, email.to.sort
    refute_email_spammyness(email)
  end

  test 'notify_others_signatures_finished_email sends email to recipient' do
    internship_agreement = create(:internship_agreement)
    create(:signature, :school_manager, internship_agreement: internship_agreement)
    create(:signature, :employer, internship_agreement: internship_agreement)
    create(:signature, :student, internship_agreement: internship_agreement)

    email = GodMailer.notify_others_signatures_finished_email(internship_agreement: internship_agreement)
    email.deliver_now
    assert_emails 1
    assert_equal [EmailUtils.from], email.from
    expected_recipients = internship_agreement.internship_application.filtered_notification_emails + [internship_agreement.school_management_representative.email, internship_agreement.internship_application.student.email]
    assert_equal expected_recipients.sort, email.to.sort
    refute_email_spammyness(email)
  end
end