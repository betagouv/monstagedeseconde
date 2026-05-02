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

    MailActionItem.create!(
      user: employer,
      action_name: "new_internship_application",
      action_type: :pending_application,
      urgency_level: :medium,
      stale_at: 2.days.from_now,
      resolved_at: nil,
      payload: { internship_application_id: submitted_application.id },
      deliveries_count: 0,
      max_deliveries_count: 1
    )

    MailActionItem.create!(
      user: employer,
      action_name: "new_internship_application",
      action_type: :pending_application,
      urgency_level: :medium,
      stale_at: 1.day.ago,
      resolved_at: nil,
      payload: { internship_application_id: read_application.id },
      deliveries_count: 0,
      max_deliveries_count: 1
    )

    assert_enqueued_emails 1 do
      Rake::Task[TASK_NAME].invoke
    end
  end
end
