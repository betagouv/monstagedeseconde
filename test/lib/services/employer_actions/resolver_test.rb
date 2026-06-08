require "test_helper"

module Services
  module EmployerActions
    class ResolverTest < ActiveSupport::TestCase
      # ---------------------------------------------------------------------------
      # pending_application — existing behaviour
      # ---------------------------------------------------------------------------
      test ".call resolves pending_application items whose application is no longer submitted" do
        employer = create(:employer)
        internship_application = create(:weekly_internship_application, :approved)

        item = MailActionItem.create!(
          recipient: employer,
          action_name: "new_internship_application",
          action_type: :pending_internship_application,
          urgency_level: :medium,
          stale_at: 5.days.from_now,
          resolved_at: nil,
          deliveries_count: 0,
          max_deliveries_count: 1,
          internship_application: internship_application
        )

        Services::EmployerActions::Resolver.call(user_id: employer.id, urgency_levels: %w[low medium])

        assert_raises(ActiveRecord::RecordNotFound) { item.reload }
      end

      test ".call does not resolve pending_application items whose application is still submitted" do
        employer = create(:employer)
        internship_application = create(:weekly_internship_application)

        item = MailActionItem.create!(
          recipient: employer,
          action_name: "new_internship_application",
          action_type: :pending_internship_application,
          urgency_level: :medium,
          stale_at: 5.days.from_now,
          resolved_at: nil,
          deliveries_count: 0,
          max_deliveries_count: 1,
          internship_application: internship_application
        )

        Services::EmployerActions::Resolver.call(user_id: employer.id, urgency_levels:  %w[low medium])

        assert_nil item.reload.resolved_at
      end

      # ---------------------------------------------------------------------------
      # restored_internship_application — never seen by employer
      # ---------------------------------------------------------------------------

      test ".call resolves restored_internship_application when application was never seen by employer" do
        internship_application = create(:weekly_internship_application, :restored)
        employer = internship_application.internship_offer.employer

        refute internship_application.has_ever_been?(%w[approved read_by_employer validated_by_employer]),
               "precondition: application must never have been seen by employer"

        item = internship_application.mail_action_items.find_by!(action_name: "restored_internship_application")

        Services::EmployerActions::Resolver.call(user_id: employer.id, urgency_levels: %w[low medium high])

        assert_raises(ActiveRecord::RecordNotFound) { item.reload }
      end

      test ".call does not resolve restored_internship_application when application was previously read_by_employer in its history" do
        internship_application = create(:weekly_internship_application, :restored)
        employer = internship_application.internship_offer.employer

        create(:internship_application_state_change,
               internship_application: internship_application,
               from_state: "submitted",
               to_state: "read_by_employer",
               author: employer)

        item = internship_application.mail_action_items.find_by!(action_name: "restored_internship_application")

        Services::EmployerActions::Resolver.call(user_id: employer.id, urgency_levels: %w[low medium high])

        assert_nothing_raised { item.reload }
        assert_nil item.reload.resolved_at
      end

      # ---------------------------------------------------------------------------
      # canceled_internship_application_by_student — never seen by employer
      # ---------------------------------------------------------------------------

      test ".call resolves canceled_internship_application_by_student when application was never seen by employer" do
        internship_application = create(:weekly_internship_application, :submitted)
        employer = internship_application.internship_offer.employer
        student = internship_application.student

        internship_application.cancel_by_student!(student)

        refute internship_application.has_ever_been?(%w[read_by_employer]),
               "precondition: application must never have been seen by employer"

        item = internship_application.mail_action_items.find_by!(action_name: "canceled_internship_application_by_student")

        Services::EmployerActions::Resolver.call(user_id: employer.id, urgency_levels: %w[low medium high])

        assert_raises(ActiveRecord::RecordNotFound) { item.reload }
      end

      test ".call does not resolve canceled_internship_application_by_student when application was previously read_by_employer" do
        internship_application = create(:weekly_internship_application, :read_by_employer)
        employer = internship_application.internship_offer.employer
        student = internship_application.student

        internship_application.cancel_by_student!(student)

        assert internship_application.has_ever_been?(%w[read_by_employer]),
               "precondition: application must have been seen by employer"

        item = internship_application.mail_action_items.find_by!(action_name: "canceled_internship_application_by_student")

        Services::EmployerActions::Resolver.call(user_id: employer.id, urgency_levels: %w[low medium high])

        assert_nothing_raised { item.reload }
        assert_nil item.reload.resolved_at
      end

      # ---------------------------------------------------------------------------
      # agreement_signed_by_all — new behaviour
      # ---------------------------------------------------------------------------

      test ".call does not resolve agreement_signed_by_all items whose agreement is nil" do
        employer = create(:employer)

        item = MailActionItem.create!(
          recipient: employer,
          action_name: "agreement_signed_by_all",
          action_type: :pending_internship_agreement,
          urgency_level: :medium,
          stale_at: 30.days.from_now,
          resolved_at: nil,
          deliveries_count: 0,
          max_deliveries_count: 1,
          internship_agreement_id: nil
        )

        Services::EmployerActions::Resolver.call(user_id: employer.id, urgency_levels:  %w[medium low])

        assert_nil item.reload.resolved_at
      end
    end
  end
end
