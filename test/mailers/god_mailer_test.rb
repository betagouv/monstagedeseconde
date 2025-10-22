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
    expected_recipients = internship_agreement.internship_application.employers_filtered_by_notifications_emails + [ internship_agreement.internship_application.student.email]
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
    expected_recipients = internship_agreement.internship_application.employers_filtered_by_notifications_emails + [
      internship_agreement.school_management_representative.email,
      internship_agreement.internship_application.student.email] +
      GodMailer.new.legal_representatives_emails(internship_agreement)
    assert_equal expected_recipients.sort, email.to.sort
    refute_email_spammyness(email)
  end

  test 'notify_signatures_enabled launches two emails' do
    internship_agreement = create(:internship_agreement, :started_by_school_manager)

    assert_emails 3 do
      internship_agreement.finalize!
    end
    # First email to all parties except legal representatives
    email1 = ActionMailer::Base.deliveries[-1]
    assert_equal [EmailUtils.from], email1.from
    expected_recipients1 = [internship_agreement.student_legal_representative_2_email]
    assert_equal expected_recipients1.sort, email1.to.sort
    assert_equal 'Imprimez et signez la convention de stage.', email1.subject
    refute_email_spammyness(email1)
    # Second email to all parties except legal representatives
    email2 = ActionMailer::Base.deliveries[-2]
    assert_equal [EmailUtils.from], email2.from
    expected_recipients2 = [internship_agreement.student_legal_representative_email]
    assert_equal expected_recipients2.sort, email2.to.sort
    assert_equal 'Imprimez et signez la convention de stage.', email2.subject
    refute_email_spammyness(email2)
    # third email
    email3 = ActionMailer::Base.deliveries[-3]
    assert_equal [EmailUtils.from], email3.from
    expected_recipients3 = internship_agreement.internship_application.employers_filtered_by_notifications_emails + [
      internship_agreement.school_management_representative.email,
      internship_agreement.internship_application.student.email]
    assert_equal expected_recipients3.sort, email3.to.sort
    assert_equal 'Imprimez et signez la convention de stage.', email3.subject
    refute_email_spammyness(email3)
  end

  test 'notify legal representatives if needed when signatures enabled' do
    internship_agreement = create(:internship_agreement, :started_by_school_manager)

    assert_emails 3 do
      internship_agreement.finalize!
    end
    # First email to legal representatives if any
    email = ActionMailer::Base.deliveries[-1]
    assert_equal [EmailUtils.from], email.from
    expected_recipients2 = [internship_agreement.student_legal_representative_2_email]
    assert_equal expected_recipients2.sort, email.to.sort
    assert_equal 'Imprimez et signez la convention de stage.', email.subject
    refute_email_spammyness(email)

    email = ActionMailer::Base.deliveries[-2]
    assert_equal [EmailUtils.from], email.from
    expected_recipients2 = [internship_agreement.student_legal_representative_email]
    assert_equal expected_recipients2.sort, email.to.sort
    assert_equal 'Imprimez et signez la convention de stage.', email.subject
    refute_email_spammyness(email)

    email = ActionMailer::Base.deliveries[-3]
    assert_equal [EmailUtils.from], email.from
    expected_recipients2 = [internship_agreement.school_manager.email, internship_agreement.employer.email, internship_agreement.student.email]
    assert_equal expected_recipients2.sort, email.to.sort
    assert_equal 'Imprimez et signez la convention de stage.', email.subject
    refute_email_spammyness(email)
  end
end