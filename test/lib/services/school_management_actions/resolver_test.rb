require "test_helper"

module Services
  module EmployerActions
    class ResolverTest < ActiveSupport::TestCase
      # ---------------------------------------------------------------------------
      # pending_application — existing behaviour
      # ---------------------------------------------------------------------------
      test ".call with school_management resolves pending_application items whose application is no longer submitted" do
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

      test ".call with school_management does not resolve pending_application items whose application is still submitted" do
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
      # agreement_signed_by_all — new behaviour
      # ---------------------------------------------------------------------------

      test ".call with school_management does not resolve agreement_signed_by_all items whose agreement is nil" do
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

  module SchoolManagementActions
    class ResolverTest < ActiveSupport::TestCase
      # ---------------------------------------------------------------------------
      # internship_agreement_completed_by_employer becomes stale once the
      # agreement is validated (B3 — "Conventions à compléter" must not linger
      # once the agreement is ready to be signed)
      # ---------------------------------------------------------------------------

      test ".call resolves internship_agreement_completed_by_employer once the agreement is validated" do
        internship_agreement = create(:mono_internship_agreement, :validated)
        school_manager = internship_agreement.school_management_representative

        refute internship_agreement.completed_by_employer?,
               "precondition: la convention ne doit plus être à l'état completed_by_employer"

        completed_item = MailActionItem.create!(
          recipient: school_manager,
          action_name: "internship_agreement_completed_by_employer",
          action_type: :pending_internship_agreement,
          urgency_level: :medium,
          stale_at: 30.days.from_now,
          resolved_at: nil,
          deliveries_count: 0,
          max_deliveries_count: 2,
          internship_agreement: internship_agreement
        )

        Services::SchoolManagementActions::Resolver.call(user_id: school_manager.id, urgency_levels: %w[low medium high critical])

        assert_raises(ActiveRecord::RecordNotFound) { completed_item.reload }
      end

      test ".call does not resolve internship_agreement_completed_by_employer while the agreement is still completed_by_employer" do
        internship_agreement = create(:mono_internship_agreement, :completed_by_employer)
        school_manager = internship_agreement.school_management_representative

        assert internship_agreement.completed_by_employer?,
               "precondition: la convention doit être à l'état completed_by_employer"

        completed_item = MailActionItem.create!(
          recipient: school_manager,
          action_name: "internship_agreement_completed_by_employer",
          action_type: :pending_internship_agreement,
          urgency_level: :medium,
          stale_at: 30.days.from_now,
          resolved_at: nil,
          deliveries_count: 0,
          max_deliveries_count: 2,
          internship_agreement: internship_agreement
        )

        Services::SchoolManagementActions::Resolver.call(user_id: school_manager.id, urgency_levels: %w[low medium high critical])

        assert_nothing_raised { completed_item.reload }
        assert_nil completed_item.reload.resolved_at
      end

      # ---------------------------------------------------------------------------
      # D5 — once all signatures are collected, the stale "agreement_to_sign"
      # item must be resolved on its own, without wiping the freshly created
      # "agreement_signed_by_all" item for the same agreement/recipient
      # (collateral resolution via agreement_resolve).
      # ---------------------------------------------------------------------------

      test ".call resolves agreement_to_sign without wiping agreement_signed_by_all once signatures are complete" do
        internship_agreement = create(:mono_internship_agreement, :signed_by_all)
        school_manager = internship_agreement.school_management_representative

        agreement_to_sign_item = MailActionItem.create!(
          recipient: school_manager,
          action_name: "agreement_to_sign",
          action_type: :pending_internship_agreement,
          urgency_level: :medium,
          stale_at: 30.days.from_now,
          resolved_at: nil,
          deliveries_count: 0,
          max_deliveries_count: 1,
          internship_agreement: internship_agreement
        )

        signed_by_all_item = MailActionItem.create!(
          recipient: school_manager,
          action_name: "agreement_signed_by_all",
          action_type: :pending_internship_agreement,
          urgency_level: :medium,
          stale_at: 30.days.from_now,
          resolved_at: nil,
          deliveries_count: 0,
          max_deliveries_count: 1,
          internship_agreement: internship_agreement
        )

        Services::SchoolManagementActions::Resolver.call(user_id: school_manager.id, urgency_levels: %w[low medium high critical])

        assert_raises(ActiveRecord::RecordNotFound) { agreement_to_sign_item.reload }
        assert_nil signed_by_all_item.reload.resolved_at
      end

      # ---------------------------------------------------------------------------
      # Once the agreement is signed by all parties, the stale
      # "signatures_enabled" item ("Conventions prêtes à être signées") must be
      # resolved so the digest doesn't show the same agreement in two sections.
      # ---------------------------------------------------------------------------

      test ".call resolves signatures_enabled once the agreement is signed by all" do
        internship_agreement = create(:mono_internship_agreement, :signed_by_all)
        school_manager = internship_agreement.school_management_representative

        signatures_enabled_item = MailActionItem.create!(
          recipient: school_manager,
          action_name: "signatures_enabled",
          action_type: :pending_internship_agreement,
          urgency_level: :medium,
          stale_at: 30.days.from_now,
          resolved_at: nil,
          deliveries_count: 0,
          max_deliveries_count: 2,
          internship_agreement: internship_agreement
        )

        signed_by_all_item = MailActionItem.create!(
          recipient: school_manager,
          action_name: "agreement_signed_by_all",
          action_type: :pending_internship_agreement,
          urgency_level: :medium,
          stale_at: 30.days.from_now,
          resolved_at: nil,
          deliveries_count: 0,
          max_deliveries_count: 1,
          internship_agreement: internship_agreement
        )

        Services::SchoolManagementActions::Resolver.call(user_id: school_manager.id, urgency_levels: %w[low medium high critical])

        assert_raises(ActiveRecord::RecordNotFound) { signatures_enabled_item.reload }
        assert_nil signed_by_all_item.reload.resolved_at
      end

      test ".call does not resolve signatures_enabled while signatures are still pending" do
        internship_agreement = create(:mono_internship_agreement, :validated)
        school_manager = internship_agreement.school_management_representative

        signatures_enabled_item = MailActionItem.create!(
          recipient: school_manager,
          action_name: "signatures_enabled",
          action_type: :pending_internship_agreement,
          urgency_level: :medium,
          stale_at: 30.days.from_now,
          resolved_at: nil,
          deliveries_count: 0,
          max_deliveries_count: 2,
          internship_agreement: internship_agreement
        )

        Services::SchoolManagementActions::Resolver.call(user_id: school_manager.id, urgency_levels: %w[low medium high critical])

        assert_nil signatures_enabled_item.reload.resolved_at
      end
    end
  end
end
