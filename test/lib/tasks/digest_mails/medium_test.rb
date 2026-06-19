require "test_helper"

class DigestMailsMediumTest < ActiveSupport::TestCase
  include ActionMailer::TestHelper
  include ActiveJob::TestHelper

  TASK_NAME = "digest_mailers:send_medium_urgency_emails".freeze

  Monstage::Application.load_tasks

  setup do
    Rake::Task[TASK_NAME].reenable
    clear_enqueued_jobs
    clear_performed_jobs
    ActionMailer::Base.deliveries = []
  end

  # Scénario B — Convention en attente de signature de l'élève
  # L'élève doit recevoir un digest medium avec les détails de la convention,
  # et ne doit PAS recevoir d'email direct "Une convention de stage attend votre signature".
  test "sends digest email to student when agreement is ready to sign, without direct email" do
    student = create(:student)
    employer = create(:employer)
    offer = create(:weekly_internship_offer_2nde, employer: employer)
    application = create(
      :weekly_internship_application,
      :approved,
      internship_offer: offer,
      student: student
    )
    agreement = application.internship_agreement

    MailActionItem.delete_all

    MailActionItem.create!(
      recipient_type: student.class.name,
      recipient_id: student.id,
      action_name: "agreement_to_sign",
      action_type: :pending_internship_agreement,
      urgency_level: :medium,
      stale_at: 2.days.from_now,
      resolved_at: nil,
      internship_application_id: application.id,
      internship_agreement_id: agreement.id,
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
    assert_equal "Résumé de vos candidatures", email.subject
    assert_match offer.employer_name, email.html_part.body.to_s
    assert_match offer.title, email.html_part.body.to_s
    refute_match "Une convention de stage attend votre signature", email.subject
  end
end
