require "test_helper"

class GodMailerTest < ActionMailer::TestCase
  include EmailSpamEuristicsAssertions

  test ".weekly_kpis_email sends email to recipient" do
    email = GodMailer.weekly_kpis_email
    email.deliver_now
    assert_emails 1
    assert_equal [ EmailUtils.from ], email.from
    assert_equal [ ENV.fetch("TEAM_DSI_EMAIL", "1e1s_team@free.fr") ], email.to
    refute_email_spammyness(email)
  end

  test "notify_others_signatures_started_email sends email to recipient" do
    internship_agreement = create(:mono_internship_agreement)
    signature = create(:signature, :school_manager, internship_agreement: internship_agreement)
    email = GodMailer.notify_others_signatures_started_email(
      internship_agreement: internship_agreement,
      missing_signatures_recipients: internship_agreement.missing_signatures_recipients,
      last_signature: signature
      )
    email.deliver_now
    assert_emails 1
    assert_equal [ EmailUtils.from ], email.from
    expected_recipients = internship_agreement.internship_application.employers_filtered_by_notifications_emails + [ internship_agreement.internship_application.student.email ]
    assert_equal expected_recipients.sort, email.to.sort
    refute_email_spammyness(email)
  end

  test "notify_others_signatures_started_email creates MailActionItem when school_manager not signed" do
    internship_agreement = create(:mono_internship_agreement)
    signature = create(:signature, :employer, internship_agreement: internship_agreement)

    assert_difference "MailActionItem.count", 1 do
      email = GodMailer.notify_others_signatures_started_email(
        internship_agreement: internship_agreement,
        missing_signatures_recipients: internship_agreement.missing_signatures_recipients,
        last_signature: signature
      )
      email.deliver_now
    end

    assert_emails 1
    assert_not_includes(
      ActionMailer::Base.deliveries.last.to,
      internship_agreement.school_management_representative.email
    )
    assert_includes ActionMailer::Base.deliveries.last.to, internship_agreement.internship_application.student.email

    mail_action_item = MailActionItem.last
    assert_equal "agreement_to_sign", mail_action_item.action_name
    assert_equal internship_agreement.school_management_representative, mail_action_item.recipient
    assert_equal internship_agreement, mail_action_item.internship_agreement
  end

  test "notify_others_signatures_finished_email sends email to recipient" do
    skip "test will be ok when getting rid of Flipper :student_signature"
    internship_agreement = create(:mono_internship_agreement)
    create(:signature, :school_manager, internship_agreement: internship_agreement)
    create(:signature, :employer, internship_agreement: internship_agreement)
    create(:signature, :student, internship_agreement: internship_agreement)

    email = GodMailer.notify_others_signatures_finished_email(internship_agreement: internship_agreement)
    email.deliver_now
    assert_emails 1
    assert_equal [ EmailUtils.from ], email.from
    expected_recipients = internship_agreement.internship_application.employers_filtered_by_notifications_emails + [
      internship_agreement.school_management_representative.email,
      internship_agreement.internship_application.student.email ] +
      GodMailer.new.legal_representatives_emails(internship_agreement)
    assert_equal expected_recipients.sort, email.to.sort
    refute_email_spammyness(email)
  end

  test "notify_others_signatures_finished_email creates MailActionItem when school_manager not signed" do
    internship_agreement = create(:mono_internship_agreement)
    create(:signature, :employer, internship_agreement: internship_agreement)
    create(:signature, :student, internship_agreement: internship_agreement)

    assert_difference "MailActionItem.count", 1 do
      email = GodMailer.notify_others_signatures_finished_email(internship_agreement: internship_agreement)
      email.deliver_now
    end

    assert_emails 1
    assert_not_includes(
      ActionMailer::Base.deliveries.last.to,
      internship_agreement.school_management_representative.email
    )

    mail_action_item = MailActionItem.last
    assert_equal "agreement_signed_by_all", mail_action_item.action_name
    assert_equal internship_agreement.school_management_representative, mail_action_item.recipient
    assert_equal internship_agreement, mail_action_item.internship_agreement
  end

  test "notify_others_signatures_finished_email does not notify school_manager when they signed last" do
    internship_agreement = create(:mono_internship_agreement)
    create(:signature, :employer, internship_agreement: internship_agreement)
    create(:signature, :student, internship_agreement: internship_agreement)
    create(:signature, :school_manager, internship_agreement: internship_agreement)

    assert_no_difference "MailActionItem.where(action_name: 'agreement_signed_by_all').count" do
      email = GodMailer.notify_others_signatures_finished_email(internship_agreement: internship_agreement)
      email.deliver_now
    end

    assert_not_includes(
      ActionMailer::Base.deliveries.last.to,
      internship_agreement.school_management_representative.email
    )
  end

  test "notify_signatures_enabled launches two emails" do
    skip "test will be ok when getting rid of Flipper :student_signature"
    internship_agreement = create(:mono_internship_agreement, :started_by_school_manager)

    assert_emails 3 do
      internship_agreement.finalize!
    end
    # First email to all parties except legal representatives
    email1 = ActionMailer::Base.deliveries[-1]
    assert_equal [ EmailUtils.from ], email1.from
    expected_recipients1 = [ internship_agreement.student_legal_representative_2_email ]
    assert_equal expected_recipients1.sort, email1.to.sort
    assert_equal "Imprimez et signez la convention de stage.", email1.subject
    refute_email_spammyness(email1)
    # Second email to all parties except legal representatives
    email2 = ActionMailer::Base.deliveries[-2]
    assert_equal [ EmailUtils.from ], email2.from
    expected_recipients2 = [ internship_agreement.student_legal_representative_email ]
    assert_equal expected_recipients2.sort, email2.to.sort
    assert_equal "Imprimez et signez la convention de stage.", email2.subject
    refute_email_spammyness(email2)
    # third email
    email3 = ActionMailer::Base.deliveries[-3]
    assert_equal [ EmailUtils.from ], email3.from
    expected_recipients3 = internship_agreement.internship_application.employers_filtered_by_notifications_emails + [
      internship_agreement.school_management_representative.email,
      internship_agreement.internship_application.student.email ]
    assert_equal expected_recipients3.sort, email3.to.sort
    assert_equal "Imprimez et signez la convention de stage.", email3.subject
    refute_email_spammyness(email3)
  end

  test "notify legal representatives if needed when signatures enabled" do
    skip "test will be ok when getting rid of Flipper :student_signature"
    internship_agreement = create(:mono_internship_agreement, :started_by_school_manager)

    assert_emails 3 do
      internship_agreement.finalize!
    end
    # First email to legal representatives if any
    email = ActionMailer::Base.deliveries[-1]
    assert_equal [ EmailUtils.from ], email.from
    expected_recipients2 = [ internship_agreement.student_legal_representative_2_email ]
    assert_equal expected_recipients2.sort, email.to.sort
    assert_equal "Imprimez et signez la convention de stage.", email.subject
    refute_email_spammyness(email)

    email = ActionMailer::Base.deliveries[-2]
    assert_equal [ EmailUtils.from ], email.from
    expected_recipients2 = [ internship_agreement.student_legal_representative_email ]
    assert_equal expected_recipients2.sort, email.to.sort
    assert_equal "Imprimez et signez la convention de stage.", email.subject
    refute_email_spammyness(email)

    email = ActionMailer::Base.deliveries[-3]
    assert_equal [ EmailUtils.from ], email.from
    expected_recipients2 = [ internship_agreement.school_manager.email, internship_agreement.employer.email, internship_agreement.student.email ]
    assert_equal expected_recipients2.sort, email.to.sort
    assert_equal "Imprimez et signez la convention de stage.", email.subject
    refute_email_spammyness(email)
  end

  test "notify_signatures_can_start_email creates MailActionItem when school_manager not signed" do
    travel_to(SchoolTrack::Seconde.both_weeks.first.monday - 1.week) do
      internship_agreement = create(:mono_internship_agreement)

      assert_difference "MailActionItem.count", 2 do
        email = GodMailer.notify_signatures_can_start_email(internship_agreement: internship_agreement)
        email.deliver_now
      end

      assert_emails 0

      school_manager = internship_agreement.school_management_representative
      school_manager_item = MailActionItem.find_by(action_name: "signatures_enabled",
                                                    recipient_type: school_manager.class.name,
                                                    recipient_id: school_manager.id)
      assert_not_nil school_manager_item
      assert_equal school_manager, school_manager_item.recipient
      assert_equal internship_agreement, school_manager_item.internship_agreement

      student_item = MailActionItem.find_by(action_name: "agreement_to_sign",
                                            recipient_id: internship_agreement.internship_application.student.id,
                                            recipient_type: "Users::Student")
      assert_not_nil student_item
      assert_equal internship_agreement, student_item.internship_agreement
    end
  end

  test "notify_signatures_can_start_email creates a MailActionItem" \
       "with stale_at set so it is picked up by the digest" do
    travel_to(SchoolTrack::Seconde.both_weeks.first.monday - 1.week) do
      internship_agreement = create(:mono_internship_agreement)

      GodMailer.notify_signatures_can_start_email(internship_agreement: internship_agreement).deliver_now

      school_manager = internship_agreement.school_management_representative
      mail_action_item = MailActionItem.find_by(action_name: "signatures_enabled",
                                                recipient_type: school_manager.class.name,
                                                recipient_id: school_manager.id)
      assert_not_nil mail_action_item
      assert_not_nil mail_action_item.stale_at
      assert_includes MailActionItem.not_overdue, mail_action_item
    end
  end

  test "notify_signatures_can_start_email does not notify the student legal representatives" do
    travel_to(SchoolTrack::Seconde.both_weeks.first.monday - 6.week) do
      internship_agreement = create(:mono_internship_agreement)

      assert_emails 0 do
        GodMailer.notify_signatures_can_start_email(internship_agreement: internship_agreement).deliver_now
      end
    end
  end

  test "notify_signatures_can_start_email excludes the cpe representative when the school has no school_manager" do
    travel_to(SchoolTrack::Seconde.both_weeks.first.monday - 6.week) do
      internship_agreement = create(:mono_internship_agreement)
      school = internship_agreement.internship_application.student.school
      school.users.where(type: "Users::SchoolManagement", role: "school_manager").destroy_all
      cpe = create(:cpe, school: school)

      assert_equal cpe, internship_agreement.school_management_representative

      # Le mailer crée 2 MailActionItems :
      # 1. "signatures_enabled" → pour le school_management_representative (CPE)
      # 2. "agreement_to_sign" → pour l'étudiant
      assert_difference "MailActionItem.count", 2 do
        email = GodMailer.notify_signatures_can_start_email(internship_agreement: internship_agreement)
        email.deliver_now
      end

      assert_emails 0

      mail_action_item = MailActionItem.find_by(action_name: "signatures_enabled",
                                                recipient_type: cpe.class.name,
                                                recipient_id: cpe.id)
      assert_not_nil mail_action_item
      assert_equal cpe, mail_action_item.recipient
      assert_equal internship_agreement, mail_action_item.internship_agreement
    end
  end
end
