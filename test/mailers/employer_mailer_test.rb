# frozen_string_literal: true

require 'test_helper'

class EmployerMailerTest < ActionMailer::TestCase
  include ::EmailSpamEuristicsAssertions
  include TeamAndAreasHelper

  test '.internship_application_submitted_email delivers as expected' do
    student = create(:student)
    internship_application = create(:weekly_internship_application, student: student)
    email = EmployerMailer.internship_application_submitted_email(internship_application: internship_application)
    email.deliver_now
    assert_emails 1
    assert_equal [internship_application.internship_offer.employer.email], email.to
    refute_email_spammyness(email)
  end

  test '.internship_application_approved_with_agreement_email delivers as expected' do
    internship_agreement = create(:internship_agreement)
    employer = internship_agreement.internship_application.internship_offer.employer
    email = EmployerMailer.internship_application_approved_with_agreement_email(
      internship_agreement: internship_agreement
    )
    email.deliver_now
    assert_emails 1
    assert_includes email.to, employer.email
    assert_equal 'Veuillez compléter la convention de stage.', email.subject
    refute_email_spammyness(email)
  end

  test '.internship_application_approved_with_agreement_email does not deliver when notifications are off' do
    internship_agreement = create(:internship_agreement)
    employer_1 = internship_agreement.internship_application.internship_offer.employer
    employer_2 = create(:employer)
    create_team(employer_1, employer_2)

    internship_agreement.internship_application
                        .internship_offer
                        .internship_offer_area
                        .area_notifications
                        .find_by(user_id: employer_1.id)
                        .update(notify: false)

    email = EmployerMailer.internship_application_approved_with_agreement_email(
      internship_agreement: internship_agreement
    )
    assert_equal [employer_2.email], email.to
  end

  test '.internship_application_approved_with_agreement_email does not deliver when notifications are off with user_operators' do
    operator               = create(:operator)
    user_operator          = create(:user_operator, operator: operator)
    internship_offer       = create(:weekly_internship_offer_2nde, employer: user_operator)
    internship_application = create(:weekly_internship_application, internship_offer: internship_offer)
    internship_agreement   = create(:internship_agreement, internship_application: internship_application)
    create_team(user_operator, create(:user_operator, operator: operator))

    internship_agreement.internship_offer_area
                        .area_notifications
                        .find_by(user_id: user_operator.id)
                        .update(notify: false)

    email = EmployerMailer.internship_application_approved_with_agreement_email(
      internship_agreement: internship_agreement
    )
    email.deliver_now
    assert_emails 1
  end

  test '.internship_application_approved_with_agreement_email does not deliver when notifications are off with department statisticians' do
    statistician           = create(:statistician, agreement_signatorable: true)
    internship_offer       = create(:weekly_internship_offer_2nde, employer: statistician)
    internship_application = create(:weekly_internship_application, internship_offer: internship_offer)
    internship_agreement   = create(:internship_agreement, internship_application: internship_application)
    create_team(statistician, create(:statistician, agreement_signatorable: true, email: 'statistician@free.fr'))

    internship_agreement.internship_offer_area
                        .area_notifications
                        .find_by(user_id: statistician.id)
                        .update(notify: false)

    email = EmployerMailer.internship_application_approved_with_agreement_email(
      internship_agreement: internship_agreement
    )
    assert_equal ['statistician@free.fr'], email.to
    email.deliver_now
    assert_emails 1
  end

  test '.resend_internship_application_submitted_email delivers as expected' do
    internship_application = create(:weekly_internship_application, :validated_by_employer)
    employer = internship_application.internship_offer.employer
    email = EmployerMailer.resend_internship_application_submitted_email(
      internship_application: internship_application
    )
    email.deliver_now
    assert_emails 1
    assert_includes email.to, employer.email
    assert_equal '[Relance] Vous avez une candidature en attente', email.subject
    refute_email_spammyness(email)
  end

  test '.school_manager_finished_notice_email delivers as expected' do
    internship_agreement = create(:internship_agreement)
    employer = internship_agreement.internship_application.internship_offer.employer
    email = EmployerMailer.school_manager_finished_notice_email(
      internship_agreement: internship_agreement
    )
    email.deliver_now
    assert_emails 1
    assert_includes email.to, employer.email
    assert_equal 'Imprimez et signez la convention de stage.', email.subject
    refute_email_spammyness(email)
  end

  test 'email informs employer when application is restored and it was read before' do
    internship_application = create(:weekly_internship_application, :restored, restored_message: 'message')
    employer = internship_application.internship_offer.employer
    email = EmployerMailer.internship_application_restored_email(internship_application: internship_application)
    email.deliver_now
    assert_emails 1
    assert_includes email.to, employer.email
    assert_equal 'Une candidature été restaurée par un élève', email.subject
    refute_email_spammyness(email)
  end

  test 'as a team member, with notifications off, it should send an email' do
    internship_offer_2nde = create_internship_offer_visible_by_two(create(:employer), create(:employer))
    internship_application = create(:weekly_internship_application, :approved,
                                    internship_offer: internship_offer_2nde)
    internship_application.cancel_by_student!
    internship_application.restored_message = ''
    employer = internship_application.internship_offer.employer
    area_id = internship_offer_2nde.internship_offer_area_id
    AreaNotification.find_by(user_id: employer.id,
                             internship_offer_area_id: area_id)
                    .update(notify: false)

    assert_emails 1 do
      internship_application.restore!
    end
  end
  test 'as a team member, with notifications on, it should send not send any email when never been approved in the past' do
    internship_offer_2nde = create_internship_offer_visible_by_two(create(:employer), create(:employer))
    internship_application = create(:weekly_internship_application, :canceled_by_student,
                                    internship_offer: internship_offer_2nde)
    internship_application.restored_message = ''

    assert_emails 0 do
      internship_application.restore!
    end
  end
end
