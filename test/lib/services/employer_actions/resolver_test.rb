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
          user: employer,
          action_name: "new_internship_application",
          action_type: :pending_internship_application,
          urgency_level: :medium,
          stale_at: 5.days.from_now,
          resolved_at: nil,
          deliveries_count: 0,
          max_deliveries_count: 1,
          internship_application: internship_application
        )

        Services::EmployerActions::Resolver.call(user_id: employer.id, urgency_levels:  %w[medium low])

        assert_not_nil item.reload.resolved_at
      end

      test ".call does not resolve pending_application items whose application is still submitted" do
        employer = create(:employer)
        internship_application = create(:weekly_internship_application)

        item = MailActionItem.create!(
          user: employer,
          action_name: "new_internship_application",
          action_type: :pending_internship_application,
          urgency_level: :medium,
          stale_at: 5.days.from_now,
          resolved_at: nil,
          deliveries_count: 0,
          max_deliveries_count: 1,
          internship_application: internship_application
        )

        Services::EmployerActions::Resolver.call(user_id: employer.id, urgency_levels:  %w[medium low])

        assert_nil item.reload.resolved_at
      end

      # ---------------------------------------------------------------------------
      # agreement_signed_by_all — new behaviour
      # ---------------------------------------------------------------------------
      test ".call resolves agreement_signed_by_all items whose agreement has been discarded" do
        employer = create(:employer)
        internship_agreement = create(:mono_internship_agreement, :signed_by_all)
        internship_agreement.discard!

        item = MailActionItem.create!(
          user: employer,
          action_name: "agreement_signed_by_all",
          action_type: :pending_internship_agreement,
          urgency_level: :medium,
          stale_at: 30.days.from_now,
          resolved_at: nil,
          deliveries_count: 0,
          max_deliveries_count: 1,
          internship_agreement: internship_agreement
        )

        Services::EmployerActions::Resolver.call(user_id: employer.id, urgency_levels:  %w[medium low])

        assert_not_nil item.reload.resolved_at
      end

      test ".call resolves agreement_signed_by_all items whose agreement is nil" do
        employer = create(:employer)

        item = MailActionItem.create!(
          user: employer,
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

        assert_not_nil item.reload.resolved_at
      end

      test ".call does not resolve agreement_signed_by_all items whose agreement is present and not discarded" do
        employer = create(:employer)
        internship_agreement = create(:mono_internship_agreement, :signed_by_all)

        item = MailActionItem.create!(
          user: employer,
          action_name: "agreement_signed_by_all",
          action_type: :pending_internship_agreement,
          urgency_level: :medium,
          stale_at: 30.days.from_now,
          resolved_at: nil,
          deliveries_count: 0,
          max_deliveries_count: 1,
          internship_agreement: internship_agreement
        )

        Services::EmployerActions::Resolver.call(user_id: employer.id, urgency_levels: %w[medium low])

        assert_nil item.reload.resolved_at
      end
    end
  end
end
