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
