require "test_helper"

class DigestMailsStudentLowTest < ActiveSupport::TestCase
  include ActionMailer::TestHelper
  include ActiveJob::TestHelper

  TASK_NAME = "digest_mailers:send_low_urgency_emails".freeze

  Monstage::Application.load_tasks

  setup do
    Rake::Task[TASK_NAME].reenable
    clear_enqueued_jobs
    clear_performed_jobs
    ActionMailer::Base.deliveries = []
  end

  # Scénario A — Candidature acceptée par l'employeur
  # L'élève doit recevoir un digest low contenant les détails de l'offre acceptée.
  test "sends digest email to student when their application was accepted by employer" do
    student = create(:student)
    employer = create(:employer)
    offer = create(:weekly_internship_offer_2nde, employer: employer)
    application = create(
      :weekly_internship_application,
      :validated_by_employer,
      internship_offer: offer,
      student: student
    )

    MailActionItem.delete_all

    MailActionItem.create!(
      recipient_type: student.class.name,
      recipient_id: student.id,
      action_name: "internship_application_validated_by_employer",
      action_type: :pending_internship_application,
      urgency_level: :high,
      stale_at: 2.days.from_now,
      resolved_at: nil,
      internship_application_id: application.id,
      deliveries_count: 0,
      max_deliveries_count: 1
    )

    assert_emails 1 do
      perform_enqueued_jobs do
        Rake::Task[TASK_NAME].invoke
      end
    end

    email = ActionMailer::Base.deliveries.last
    refute_nil email
    assert_includes email.to, student.email
    assert_match offer.employer_name, email.html_part.body.to_s
    assert_match offer.title, email.html_part.body.to_s
    assert_match application.presenter(student).date_range, email.html_part.body.to_s
  end
end
