require "test_helper"

# Scénario D — Un digest medium regroupe actions medium et high en un seul mail
class DigestMailsStudentMediumMultiUrgencyTest < ActiveSupport::TestCase
  include ActionMailer::TestHelper
  include ActiveJob::TestHelper

  TASK_NAME = "digest_mailers:send_medium_urgency_emails".freeze

  Monstage::Application.load_tasks

  setup do
    Rake::Task[TASK_NAME].reenable
    clear_enqueued_jobs
    clear_performed_jobs
    ActionMailer::Base.deliveries = []
    MailActionItem.delete_all
  end

  test "sends a single digest email grouping medium and high actions" do
    student = create(:student)
    employer = create(:employer)

    offer_to_sign = create(:weekly_internship_offer_2nde, employer: employer)
    application_to_sign = create(
      :weekly_internship_application,
      :approved,
      internship_offer: offer_to_sign,
      student: student
    )
    agreement = application_to_sign.internship_agreement

    offer_validated = create(:weekly_internship_offer_2nde, employer: employer)
    application_validated = create(
      :weekly_internship_application,
      :validated_by_employer,
      internship_offer: offer_validated,
      student: student
    )

    # Action medium : convention en attente de signature
    MailActionItem.create!(
      recipient_type: student.class.name,
      recipient_id: student.id,
      action_name: "agreement_to_sign",
      action_type: :pending_internship_agreement,
      urgency_level: :medium,
      stale_at: 7.days.from_now,
      resolved_at: nil,
      internship_application_id: application_to_sign.id,
      internship_agreement_id: agreement.id,
      deliveries_count: 0,
      max_deliveries_count: 1
    )

    # Action high : candidature acceptée par l'employeur
    MailActionItem.create!(
      recipient_type: student.class.name,
      recipient_id: student.id,
      action_name: "internship_application_validated_by_employer",
      action_type: :pending_internship_application,
      urgency_level: :high,
      stale_at: 7.days.from_now,
      resolved_at: nil,
      internship_application_id: application_validated.id,
      deliveries_count: 0,
      max_deliveries_count: 1
    )

    assert_emails 1 do
      perform_enqueued_jobs do
        Rake::Task[TASK_NAME].invoke
      end
    end

    email = ActionMailer::Base.deliveries.select { |e| e.to.include?(student.email) }.last
    assert_not_nil email, "L'élève doit recevoir un email de digest"

    html_body = email.html_part.body.to_s
    assert_match offer_to_sign.title, html_body, "Le mail doit contenir l'offre à signer (medium)"
    assert_match offer_validated.title, html_body, "Le mail doit contenir l'offre validée (high)"
  end
end
