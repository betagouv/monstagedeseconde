require "test_helper"

class DigestMailslowTest < ActiveSupport::TestCase
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

  test "sends digest email only for submitted internship applications" do
    employer = create(:employer)

    submitted_offer = create(:weekly_internship_offer_2nde, employer: employer)
    submitted_application = create(
      :weekly_internship_application,
      :submitted,
      internship_offer: submitted_offer
    )

    read_offer = create(:weekly_internship_offer_2nde, employer: employer)
    read_application = create(
      :weekly_internship_application,
      :read_by_employer,
      internship_offer: read_offer
    )

    # Clear auto-created MailActionItems from notify_users callback and create controlled ones
    MailActionItem.delete_all

    MailActionItem.create!(
      recipient: employer,
      action_name: "new_internship_application",
      action_type: :pending_internship_application,
      urgency_level: :low,
      stale_at: 2.days.from_now,
      resolved_at: nil,
      internship_application_id: submitted_application.id,
      deliveries_count: 0,
      max_deliveries_count: 1
    )

    MailActionItem.create!(
      recipient: employer,
      action_name: "new_internship_application",
      action_type: :pending_internship_application,
      urgency_level: :low,
      stale_at: 1.day.ago,
      resolved_at: nil,
      internship_application_id: read_application.id,
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
    assert_includes email.to, employer.email
    assert_match submitted_application.student.presenter.full_name, email.html_part.body.to_s
    assert_match submitted_application.student.school.name, email.html_part.body.to_s
  end
end
