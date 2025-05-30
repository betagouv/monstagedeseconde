# frozen_string_literal: true

require 'test_helper'

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

    test 'perform does not expire '\
         'when internship_applications is pending for less than EXPIRATION_DURATION' do
      internship_application = create(:weekly_internship_application, :submitted,
                                      submitted_at: Time.now - InternshipApplication::EXPIRATION_DURATION + 1.day,
                                      internship_offer: @internship_offer)
      internship_application_2 = create(:weekly_internship_application, :submitted,
                                        submitted_at: 1.day.ago,
                                        aasm_state: 'validated_by_employer',
                                        internship_offer: @internship_offer)
      InternshipApplicationsExpirerJob.perform_now(@internship_offer.employer)
      internship_application.reload
      assert_nil internship_application.pending_reminder_sent_at
      assert_nil internship_application.expired_at
      assert internship_application.submitted?
    end
    test 'perform does expire ' \
         'when internship_applications is pending for more than EXPIRATION_DURATION' do
      internship_application = create(:weekly_internship_application, :submitted,
                                      submitted_at: Time.now - InternshipApplication::EXPIRATION_DURATION - 5.days,
                                      internship_offer: @internship_offer)
      InternshipApplicationsExpirerJob.perform_now(@internship_offer.employer)
      internship_application.reload
      assert_nil internship_application.pending_reminder_sent_at
      refute_nil internship_application.expired_at
      assert internship_application.expired?
    end

    test 'perform expire! when internship_applications is pending for more than EXPIRATION_DURATION' do
      internship_application = nil
      assert_enqueued_emails 1 do # one for student internship_application_expired_email
        internship_application = create(:weekly_internship_application, :submitted,
                                        submitted_at: (InternshipApplication::EXPIRATION_DURATION + 1.day).ago,
                                        pending_reminder_sent_at: 7.days.ago,
                                        internship_offer: @internship_offer)
      end

      freeze_time do
        assert_changes -> { internship_application.reload.expired? },
                       from: false,
                       to: true do
          InternshipApplicationsExpirerJob.perform_now(@internship_offer.employer)
          assert_enqueued_emails 1 # for student
        end
        internship_application.reload
        assert_equal Time.now.utc, internship_application.expired_at, 'expired_at not updated'
        refute_equal DateTime.now, internship_application.pending_reminder_sent_at
      end
      assert_no_emails do # ensure re-entrance does not send emails
        InternshipApplicationsExpirerJob.perform_now(@internship_offer.employer)
      end
    end
  end
end
