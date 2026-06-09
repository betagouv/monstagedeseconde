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

      test ".call does not resolve new_internship_application when application is restored and never seen by employer (D2)" do
        internship_application = create(:weekly_internship_application, :restored)
        employer = internship_application.internship_offer.employer

        refute internship_application.has_ever_been?(%w[read_by_employer]),
               "precondition: application must never have been seen by employer"

        new_item = MailActionItem.create!(
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

        Services::EmployerActions::Resolver.call(user_id: employer.id, urgency_levels: %w[low medium high])

        assert_nothing_raised { new_item.reload }
        assert_nil new_item.reload.resolved_at,
                   "new_internship_application doit rester dans le digest quand l'application est restaurée et jamais lue"
      end

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

      test ".call does not resolve restored_internship_application as collateral damage from new_internship_application resolution when application was read, canceled, then restored" do
        internship_application = create(:weekly_internship_application, :read_by_employer)
        employer = internship_application.internship_offer.employer
        student = internship_application.student

        internship_application.cancel_by_student!(student)
        internship_application.restore!(student)

        assert internship_application.has_ever_been?(%w[read_by_employer]),
               "precondition: application must have been seen by employer"

        item = internship_application.mail_action_items.find_by!(action_name: "restored_internship_application")

        Services::EmployerActions::Resolver.call(user_id: employer.id, urgency_levels: %w[low medium high])

        assert_nothing_raised { item.reload }
        assert_nil item.reload.resolved_at
      end

      test ".call resolves restored_internship_application when application was read, canceled, restored, then re-canceled before digest (D3)" do
        internship_application = create(:weekly_internship_application, :read_by_employer)
        employer = internship_application.internship_offer.employer
        student = internship_application.student

        internship_application.cancel_by_student!(student)
        internship_application.restore!(student)
        internship_application.cancel_by_student!(student)

        assert internship_application.has_ever_been?(%w[read_by_employer]),
               "precondition: application must have been seen by employer"
        refute_equal "restored", internship_application.aasm_state,
                     "precondition: application must no longer be in restored state"

        restored_item = internship_application.mail_action_items.find_by!(action_name: "restored_internship_application")
        canceled_items = internship_application.mail_action_items.where(action_name: "canceled_internship_application_by_student")

        assert_equal 1, canceled_items.count,
                     "precondition: exactement un item d'annulation doit exister"

        Services::EmployerActions::Resolver.call(user_id: employer.id, urgency_levels: %w[low medium high])

        assert_raises(ActiveRecord::RecordNotFound) { restored_item.reload }

        surviving_canceled = internship_application.mail_action_items.where(action_name: "canceled_internship_application_by_student")
        assert_equal 1, surviving_canceled.count,
                     "l'annulation doit être signalée exactement une fois dans le digest"
        assert_nil surviving_canceled.first.resolved_at,
                   "l'item d'annulation ne doit pas être résolu"
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
      # cancel_by_student_confirmation — must survive collateral resolution
      # ---------------------------------------------------------------------------

      test ".call does not resolve cancel_by_student_confirmation as collateral damage from new_internship_application resolution" do
        internship_application = create(:weekly_internship_application, :read_by_employer)
        employer = internship_application.internship_offer.employer
        student = internship_application.student

        internship_application.cancel_by_student_confirmation!(student)

        item = internship_application.mail_action_items.find_by!(action_name: "cancel_by_student_confirmation")

        Services::EmployerActions::Resolver.call(user_id: employer.id, urgency_levels: %w[low medium high])

        assert_nothing_raised { item.reload }
        assert_nil item.reload.resolved_at
      end

      # ---------------------------------------------------------------------------
      # new_agreement_to_fill_in — F4
      # ---------------------------------------------------------------------------

      test ".call resolves new_agreement_to_fill_in when agreement is no longer draft (F4)" do
        internship_agreement = create(:mono_internship_agreement, :signatures_started)
        employer = internship_agreement.employer

        refute internship_agreement.draft?,
               "precondition: la convention ne doit plus être à l'état draft"

        item = MailActionItem.create!(
          recipient: employer,
          action_name: "new_agreement_to_fill_in",
          action_type: :pending_internship_agreement,
          urgency_level: :medium,
          stale_at: 30.days.from_now,
          resolved_at: nil,
          deliveries_count: 0,
          max_deliveries_count: 1,
          internship_agreement: internship_agreement
        )

        Services::EmployerActions::Resolver.call(user_id: employer.id, urgency_levels: %w[low medium high])

        assert_raises(ActiveRecord::RecordNotFound) { item.reload }
      end

      test ".call does not resolve new_agreement_to_fill_in when agreement is still draft" do
        internship_agreement = create(:mono_internship_agreement, :draft)
        employer = internship_agreement.employer

        assert internship_agreement.draft?,
               "precondition: la convention doit être à l'état draft"

        item = MailActionItem.create!(
          recipient: employer,
          action_name: "new_agreement_to_fill_in",
          action_type: :pending_internship_agreement,
          urgency_level: :medium,
          stale_at: 30.days.from_now,
          resolved_at: nil,
          deliveries_count: 0,
          max_deliveries_count: 1,
          internship_agreement: internship_agreement
        )

        Services::EmployerActions::Resolver.call(user_id: employer.id, urgency_levels: %w[low medium high])

        assert_nil item.reload.resolved_at
      end

      test ".call does not resolve agreement_to_sign as collateral damage when new_agreement_to_fill_in is resolved (F4 collateral)" do
        internship_agreement = create(:mono_internship_agreement, :signatures_started)
        employer = internship_agreement.employer

        refute internship_agreement.draft?,
               "precondition: la convention ne doit plus être à l'état draft"
        assert internship_agreement.roles_not_signed_yet.include?("employer"),
               "precondition: l'employeur n'a pas encore signé"

        fill_in_item = MailActionItem.create!(
          recipient: employer,
          action_name: "new_agreement_to_fill_in",
          action_type: :pending_internship_agreement,
          urgency_level: :medium,
          stale_at: 30.days.from_now,
          resolved_at: nil,
          deliveries_count: 0,
          max_deliveries_count: 1,
          internship_agreement: internship_agreement
        )

        to_sign_item = MailActionItem.create!(
          recipient: employer,
          action_name: "agreement_to_sign",
          action_type: :pending_internship_agreement,
          urgency_level: :medium,
          stale_at: 30.days.from_now,
          resolved_at: nil,
          deliveries_count: 0,
          max_deliveries_count: 1,
          internship_agreement: internship_agreement
        )

        Services::EmployerActions::Resolver.call(user_id: employer.id, urgency_levels: %w[low medium high])

        assert_raises(ActiveRecord::RecordNotFound) { fill_in_item.reload }
        assert_nothing_raised { to_sign_item.reload }
        assert_nil to_sign_item.reload.resolved_at,
                   "agreement_to_sign ne doit pas être résolu comme dommage collatéral"
      end

      # ---------------------------------------------------------------------------
      # agreement_to_sign resolved when employer signs — F6
      # ---------------------------------------------------------------------------

      test ".call resolves agreement_to_sign when employer has signed (F6)" do
        internship_agreement = create(:mono_internship_agreement, :signed_by_employer_only)
        employer = internship_agreement.employer

        refute internship_agreement.roles_not_signed_yet.include?("employer"),
               "precondition: l'employeur a déjà signé"

        item = MailActionItem.create!(
          recipient: employer,
          action_name: "agreement_to_sign",
          action_type: :pending_internship_agreement,
          urgency_level: :medium,
          stale_at: 30.days.from_now,
          resolved_at: nil,
          deliveries_count: 0,
          max_deliveries_count: 1,
          internship_agreement: internship_agreement
        )

        Services::EmployerActions::Resolver.call(user_id: employer.id, urgency_levels: %w[low medium high])

        assert_raises(ActiveRecord::RecordNotFound) { item.reload }
      end

      test ".call resolves agreement_signed_by_all when employer was the last to sign (F6)" do
        internship_agreement = create(:mono_internship_agreement, :signed_by_all)
        employer = internship_agreement.employer

        assert internship_agreement.signed_by_all?,
               "precondition: la convention doit être signée par tous"
        assert internship_agreement.signed_by_employer?,
               "precondition: l'employeur a signé"

        item = MailActionItem.create!(
          recipient: employer,
          action_name: "agreement_signed_by_all",
          action_type: :pending_internship_agreement,
          urgency_level: :medium,
          stale_at: 30.days.from_now,
          resolved_at: nil,
          deliveries_count: 0,
          max_deliveries_count: 1,
          internship_agreement: internship_agreement
        )

        Services::EmployerActions::Resolver.call(user_id: employer.id, urgency_levels: %w[low medium high])

        assert_raises(ActiveRecord::RecordNotFound) { item.reload }
      end

      test ".call does not resolve agreement_signed_by_all when employer has not signed (autres signataires en premier)" do
        internship_agreement = create(:mono_internship_agreement, :signed_by_school_manager_only)
        employer = internship_agreement.employer

        assert internship_agreement.roles_not_signed_yet.include?("employer"),
               "precondition: l'employeur n'a pas encore signé"

        item = MailActionItem.create!(
          recipient: employer,
          action_name: "agreement_signed_by_all",
          action_type: :pending_internship_agreement,
          urgency_level: :medium,
          stale_at: 30.days.from_now,
          resolved_at: nil,
          deliveries_count: 0,
          max_deliveries_count: 1,
          internship_agreement: internship_agreement
        )

        Services::EmployerActions::Resolver.call(user_id: employer.id, urgency_levels: %w[low medium high])

        assert_nothing_raised { item.reload }
        assert_nil item.reload.resolved_at,
                   "agreement_signed_by_all ne doit pas être résolu si l'employeur n'a pas signé"
      end

      test ".call resolves all pending agreement items when agreement is signed_by_all (F6 nettoyage complet)" do
        internship_agreement = create(:mono_internship_agreement, :signed_by_all)
        employer = internship_agreement.employer

        assert internship_agreement.signed_by_all?, "precondition"
        assert internship_agreement.signed_by_employer?, "precondition"

        fill_in_item = MailActionItem.create!(
          recipient: employer, action_name: "new_agreement_to_fill_in",
          action_type: :pending_internship_agreement, urgency_level: :medium,
          stale_at: 30.days.from_now, resolved_at: nil,
          deliveries_count: 0, max_deliveries_count: 2,
          internship_agreement: internship_agreement
        )
        signatures_enabled_item = MailActionItem.create!(
          recipient: employer, action_name: "signatures_enabled",
          action_type: :pending_internship_agreement, urgency_level: :medium,
          stale_at: 30.days.from_now, resolved_at: nil,
          deliveries_count: 0, max_deliveries_count: 2,
          internship_agreement: internship_agreement
        )
        to_sign_item = MailActionItem.create!(
          recipient: employer, action_name: "agreement_to_sign",
          action_type: :pending_internship_agreement, urgency_level: :medium,
          stale_at: 30.days.from_now, resolved_at: nil,
          deliveries_count: 0, max_deliveries_count: 1,
          internship_agreement: internship_agreement
        )
        signed_by_another_item = MailActionItem.create!(
          recipient: employer, action_name: "agreement_signed_by_another",
          action_type: :pending_internship_agreement, urgency_level: :low,
          stale_at: 30.days.from_now, resolved_at: nil,
          deliveries_count: 0, max_deliveries_count: 1,
          internship_agreement: internship_agreement
        )
        signed_by_all_item = MailActionItem.create!(
          recipient: employer, action_name: "agreement_signed_by_all",
          action_type: :pending_internship_agreement, urgency_level: :medium,
          stale_at: 30.days.from_now, resolved_at: nil,
          deliveries_count: 0, max_deliveries_count: 1,
          internship_agreement: internship_agreement
        )

        Services::EmployerActions::Resolver.call(user_id: employer.id, urgency_levels: %w[low medium high])

        [fill_in_item, signatures_enabled_item, to_sign_item, signed_by_another_item, signed_by_all_item].each do |item|
          assert_raises(ActiveRecord::RecordNotFound) { item.reload }
        end
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
