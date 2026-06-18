# frozen_string_literal: true

require "test_helper"

module Triggered
  class InternshipApplicationsExpirerJobTest < ActiveJob::TestCase
    include ActionMailer::TestHelper

    # @warning: sometimes it fails ; surprising,
    # try to empty deliveries before running the spec
    setup do
      @internship_offer = create(:weekly_internship_offer_2nde)
      ActionMailer::Base.deliveries = []
    end

    teardown { ActionMailer::Base.deliveries = [] }

    test "perform does not expire "\
         "when internship_applications is pending for less than EXPIRATION_DURATION" do
      internship_application = create(:weekly_internship_application, :submitted,
                                      submitted_at: Time.now - InternshipApplication::EXPIRATION_DURATION + 1.day,
                                      internship_offer: @internship_offer)
      internship_application_2 = create(:weekly_internship_application, :submitted,
                                        submitted_at: 1.day.ago,
                                        aasm_state: "validated_by_employer",
                                        internship_offer: @internship_offer)
      InternshipApplicationsExpirerJob.perform_now(@internship_offer.employer)
      internship_application.reload
      assert_nil internship_application.pending_reminder_sent_at
      assert_nil internship_application.expired_at
      assert internship_application.submitted?
    end

    test "perform does expire " \
         "when internship_applications is pending for more than EXPIRATION_DURATION" do
      internship_application = create(:weekly_internship_application, :submitted,
                                      submitted_at: Time.now - InternshipApplication::EXPIRATION_DURATION - 5.days,
                                      internship_offer: @internship_offer)
      InternshipApplicationsExpirerJob.perform_now(@internship_offer.employer)
      internship_application.reload
      assert_nil internship_application.pending_reminder_sent_at
      refute_nil internship_application.expired_at
      assert internship_application.expired?
    end

    test "perform expire! when internship_applications is pending for more than EXPIRATION_DURATION" do
      internship_application = create(:weekly_internship_application, :submitted,
                                      submitted_at: (InternshipApplication::EXPIRATION_DURATION + 1.day).ago,
                                      pending_reminder_sent_at: 7.days.ago,
                                      internship_offer: @internship_offer)
      ActionMailer::Base.deliveries = [] # reset emails from creation callbacks
      clear_enqueued_jobs # reset enqueued jobs from creation callbacks

      assert_changes -> { internship_application.reload.expired? },
                    from: false,
                    to: true do
        assert_difference "MailActionItem.count", 1 do # digest email for student
          InternshipApplicationsExpirerJob.perform_now(@internship_offer.employer)
        end
      end
      internship_application.reload
      assert_in_delta Time.current.utc, internship_application.expired_at, 2.second
      refute_equal Time.current, internship_application.pending_reminder_sent_at
      assert_no_emails do # ensure re-entrance does not send emails
        InternshipApplicationsExpirerJob.perform_now(@internship_offer.employer)
      end
    end
  end
end
