# frozen_string_literal: true

require 'application_system_test_case'

class StudentDigestAgreementSignedByAllTest < ApplicationSystemTestCase
  include Devise::Test::IntegrationHelpers
  include ActionMailer::TestHelper
  include ActiveJob::TestHelper

  Monstage::Application.load_tasks

  setup do
    travel_to Time.zone.local(2025, 3, 15)
    Rake::Task['digest_mailers:send_medium_urgency_emails'].reenable
  end

  teardown do
    travel_back
  end

  test "scenario C: student receives digest email when agreement is signed by all parties" do
    student = create(:student)
    internship_offer = create(:weekly_internship_offer_3eme)

    # Create internship agreement with all signatures
    internship_application = create(:weekly_internship_application,
                                    student:,
                                    internship_offer:)
    internship_agreement = create(:mono_internship_agreement,
                                  internship_application:,
                                  skip_notifications_when_system_creation: false)

    # Create agreement_signed_by_all action manually since the workflow is complex
    # (normally created when last signature is added and agreement transitions to signed_by_all)
    clear_enqueued_jobs
    MailActionItem.create!(
      recipient_type: student.class.name,
      recipient_id: student.id,
      action_name: "agreement_signed_by_all",
      action_type: :pending_internship_agreement,
      urgency_level: :medium,
      stale_at: 5.days.from_now,
      resolved_at: nil,
      internship_agreement_id: internship_agreement.id,
      deliveries_count: 0,
      max_deliveries_count: 1
    )

    # Trigger the medium urgency digest
    clear_enqueued_jobs
    perform_enqueued_jobs do
      Rake::Task['digest_mailers:send_medium_urgency_emails'].invoke
    end

    # Check the email content (last email should be for student)
    email = ActionMailer::Base.deliveries.select { |e| e.to.include?(student.email) }.last
    assert_not_nil email, "Email should be delivered to student"
    assert_equal [student.email], email.to
    assert_includes email.subject, 'Résumé'

    # Verify the section "Conventions signées par toutes les parties" is present
    text_body = email.text_part&.body&.to_s || ""
    html_body = email.html_part&.body&.to_s || ""

    assert_match(/Conventions signées par toutes les parties/i, text_body,
                 "Text email should contain 'Conventions signées par toutes les parties' section")
    assert_match(/Conventions signées par toutes les parties/i, html_body,
                 "HTML email should contain 'Conventions signées par toutes les parties' section")

    # Verify offer details in email
    assert_includes text_body, internship_offer.title,
                    "Email text should contain offer title"
    # Employer name rendering depends on offer's employer_name field
    employer_name = internship_offer.employer_name.presence || internship_offer.employer.name
    assert_includes text_body, employer_name,
                    "Email text should contain employer name (either from offer or employer)"
    assert_includes html_body, internship_offer.title,
                    "Email HTML should contain offer title"
  end

  test "full workflow: student signs and receives agreement_signed_by_all digest email" do
    # Full scenario: application → validation → all signatures → digest
    student = create(:student)
    internship_offer = create(:weekly_internship_offer_3eme)

    # 1. Create application (student applies)
    internship_application = create(:weekly_internship_application,
                                    student:,
                                    internship_offer:,
                                    aasm_state: :approved)

    # 2. Create agreement (convention ready to sign)
    clear_enqueued_jobs
    internship_agreement = create(:mono_internship_agreement,
                                  internship_application:,
                                  skip_notifications_when_system_creation: false,
                                  aasm_state: "signatures_started")

    # Clear the "agreement_to_sign" action that was created on agreement creation
    MailActionItem.where(
      internship_agreement_id: internship_agreement.id,
      action_name: "agreement_to_sign"
    ).delete_all

    # 3. Student signs
    clear_enqueued_jobs
    student_signature = create(:signature,
                               :student,
                               internship_agreement: internship_agreement,
                               user_id: student.id)
    internship_agreement.sign!

    # 4. Student legal representative signs
    student_legal_rep_signature = create(:signature,
                                         :student_legal_representative,
                                         internship_agreement: internship_agreement,
                                         user_id: student.id)  # using student's ID for simplicity
    internship_agreement.sign!

    # 5. Employer signs
    employer_signature = create(:signature,
                                :employer,
                                internship_agreement: internship_agreement,
                                user_id: internship_agreement.employer.id)
    internship_agreement.sign!

    # 6. School manager signs - THIS should trigger transition to signed_by_all and create agreement_signed_by_all
    school_manager_signature = create(:signature,
                                      :school_manager,
                                      internship_agreement: internship_agreement,
                                      user_id: internship_agreement.school_manager.id)
    internship_agreement.sign!

    # Verify that agreement is now signed_by_all
    assert_equal "signed_by_all", internship_agreement.reload.aasm_state,
                 "Agreement should be in signed_by_all state after all signatures"

    # Verify that agreement_signed_by_all action was created
    agreement_signed_by_all_item = MailActionItem.find_by(
      recipient_id: student.id,
      action_name: "agreement_signed_by_all",
      internship_agreement_id: internship_agreement.id
    )
    assert_not_nil agreement_signed_by_all_item,
                  "MailActionItem with agreement_signed_by_all should be created when agreement is fully signed"

    # Clear jobs and trigger digest
    clear_enqueued_jobs
    perform_enqueued_jobs do
      Rake::Task['digest_mailers:send_medium_urgency_emails'].invoke
    end

    # Check the email
    email = ActionMailer::Base.deliveries.select { |e| e.to.include?(student.email) }.last
    assert_not_nil email, "Email should be delivered to student"
    assert_includes email.subject, 'Résumé'

    # Verify the section is present
    text_body = email.text_part&.body&.to_s || ""
    assert_match(/Conventions signées par toutes les parties/i, text_body,
                 "Text email should contain 'Conventions signées par toutes les parties' section")

    # Verify agreement_signed_by_all was marked as delivered
    assert_equal 1, agreement_signed_by_all_item.reload.deliveries_count,
                "agreement_signed_by_all should have been delivered"
  end

  test "agreement_signed_by_all action stays pending after resolver runs" do
    student = create(:student)
    internship_offer = create(:weekly_internship_offer_3eme)

    internship_application = create(:weekly_internship_application,
                                    student:,
                                    internship_offer:)
    internship_agreement = create(:mono_internship_agreement,
                                  internship_application:)

    item = MailActionItem.create!(
      recipient_type: student.class.name,
      recipient_id: student.id,
      action_name: "agreement_signed_by_all",
      action_type: :pending_internship_agreement,
      urgency_level: :medium,
      stale_at: 5.days.from_now,
      resolved_at: nil,
      internship_agreement_id: internship_agreement.id,
      deliveries_count: 0,
      max_deliveries_count: 1
    )

    # Run resolver
    Services::StudentActions::Resolver.call(user_id: student.id, urgency_levels: %w[medium])

    # agreement_signed_by_all should still be pending
    assert_nil item.reload.resolved_at,
              "agreement_signed_by_all should be pending (not auto-resolved by extra_resolver)"
  end

end
