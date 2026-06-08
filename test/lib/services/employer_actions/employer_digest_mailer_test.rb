require "test_helper"

module Services
  module EmployerActions
    class EmployerDigestMailerTest < ActiveSupport::TestCase
      test ".purge_actions_for_user_and_level removes stale resolved and maxed" do
        employer = create(:employer)

        kept = MailActionItem.create!(
          recipient: employer,
          action_name: "internship_offer_removed",
          action_type: :pending_internship_offer,
          urgency_level: :medium,
          stale_at: 2.days.from_now,
          resolved_at: nil,
          deliveries_count: 0,
          max_deliveries_count: 1
        )

        MailActionItem.create!(
          recipient: employer,
          action_name: "internship_offer_removed",
          action_type: :pending_internship_offer,
          urgency_level: :medium,
          stale_at: 2.days.from_now,
          resolved_at: Time.current,
          deliveries_count: 0,
          max_deliveries_count: 1
        )

        MailActionItem.create!(
          recipient: employer,
          action_name: "internship_offer_removed",
          action_type: :pending_internship_offer,
          urgency_level: :medium,
          stale_at: 1.day.ago,
          resolved_at: nil,
          deliveries_count: 0,
          max_deliveries_count: 1
        )

        MailActionItem.create!(
          recipient: employer,
          action_name: "internship_offer_removed",
          action_type: :pending_internship_offer,
          urgency_level: :medium,
          stale_at: 2.days.from_now,
          resolved_at: nil,
          deliveries_count: 2,
          max_deliveries_count: 1
        )

        Services::EmployerActions::Resolver.call(
          user_id: employer.id,
          urgency_levels: %w[low medium]
        )

        assert_equal [ kept.id ],
                     MailActionItem.where(recipient: employer).pluck(:id)
      end

      test "#find_actions filters out empty action groups" do
        item = Struct.new(:id).new(123)

        fake_actions = {
          "pending_internship_application" => [ item ],
          "agreement_to_sign" => []
        }

        Services::EmployerActions::DigestBuilder.stub(
          :build_digest_by_user_and_urgency_level,
          fake_actions
        ) do
          result = Services::EmployerActions::EmployerDigestMailer.find_actions(
            user_id: 1,
            urgency_levels: [ "medium" ]
          )
          assert_equal [ "pending_internship_application" ], result.keys
        end
      end

      test "#find_actions returns empty hash when digest is empty" do
        Services::EmployerActions::DigestBuilder.stub(
          :build_digest_by_user_and_urgency_level,
          {}
        ) do
          assert_equal({},
                       Services::EmployerActions::EmployerDigestMailer.find_actions(
                         user_id: 1,
                         urgency_levels: [ "medium" ]
                       ))
        end
      end

      test ".perform_for_medium_level delivers for canceled_internship_application_by_student when previously read" do
        internship_application = create(:weekly_internship_application, :canceled_by_student)
        employer = internship_application.internship_offer.employer
        create(:internship_application_state_change,
               internship_application: internship_application,
               from_state: "submitted",
               to_state: "read_by_employer",
               author: employer)
        MailActionItem.delete_all

        item = MailActionItem.create!(
          recipient: employer,
          action_name: "canceled_internship_application_by_student",
          action_type: :pending_internship_application,
          internship_application:,
          urgency_level: :medium,
          stale_at: 30.days.from_now,
          resolved_at: nil,
          deliveries_count: 0,
          max_deliveries_count: 1
        )

        Services::EmployerActions::EmployerDigestMailer.perform_for_medium_level(user_id: employer.id)

        assert_equal [ item.id ],
                     MailActionItem.where(recipient: employer, deliveries_count: 1).pluck(:id)
      end

      test ".perform_for_medium_level delivers for restored_internship_application when previously read" do
        internship_application = create(:weekly_internship_application, :restored)
        employer = internship_application.internship_offer.employer
        create(:internship_application_state_change,
               internship_application: internship_application,
               from_state: "submitted",
               to_state: "read_by_employer",
               author: employer)
        MailActionItem.delete_all

        item = MailActionItem.create!(
          recipient: employer,
          action_name: "restored_internship_application",
          action_type: :pending_internship_application,
          internship_application:,
          urgency_level: :medium,
          stale_at: 30.days.from_now,
          resolved_at: nil,
          deliveries_count: 0,
          max_deliveries_count: 1
        )

        Services::EmployerActions::EmployerDigestMailer.perform_for_medium_level(user_id: employer.id)

        assert_equal [ item.id ],
                     MailActionItem.where(recipient: employer, deliveries_count: 1).pluck(:id)
      end

      test ".perform_for_high_level delivers for cancel_by_student_confirmation" do
        internship_application = create(:weekly_internship_application, :submitted)
        employer = internship_application.internship_offer.employer
        internship_application.update_columns(aasm_state: "canceled_by_student_confirmation")
        MailActionItem.delete_all

        item = MailActionItem.create!(
          recipient: employer,
          action_name: "cancel_by_student_confirmation",
          action_type: :pending_internship_application,
          internship_application:,
          urgency_level: :high,
          stale_at: 30.days.from_now,
          resolved_at: nil,
          deliveries_count: 0,
          max_deliveries_count: 1
        )

        Services::EmployerActions::EmployerDigestMailer.perform_for_high_level(user_id: employer.id)

        assert_equal [ item.id ],
                     MailActionItem.where(recipient: employer, deliveries_count: 1).pluck(:id)
      end

      test "#perform_for_low_level performs expected operations" do
        internship_application = create(:weekly_internship_application)
        employer = internship_application.internship_offer.employer
        MailActionItem.delete_all

        valid_medium = MailActionItem.create!(
          recipient: employer,
          action_name: "new_internship_application",
          action_type: :pending_internship_application,
          internship_application:,
          urgency_level: :medium,
          stale_at: 4.days.from_now,
          resolved_at: nil,
          deliveries_count: 0,
          max_deliveries_count: 1
        )

        Services::EmployerActions::EmployerDigestMailer.perform_for_medium_level(user_id: employer.id)

        assert_equal [ valid_medium.id ],
                     MailActionItem.where(recipient: employer, deliveries_count: 1).pluck(:id)
      end

      test ".perform_for_medium_level does NOT notify employer when application was canceled without being read" do
        internship_application = create(:weekly_internship_application, :canceled_by_student)
        employer = internship_application.internship_offer.employer
        MailActionItem.delete_all

        MailActionItem.create!(
          recipient: employer,
          action_name: "canceled_internship_application_by_student",
          action_type: :pending_internship_application,
          internship_application:,
          urgency_level: :medium,
          stale_at: 30.days.from_now,
          resolved_at: nil,
          deliveries_count: 0,
          max_deliveries_count: 1
        )

        Services::EmployerActions::EmployerDigestMailer.perform_for_medium_level(user_id: employer.id)

        assert_equal 0, MailActionItem.where(recipient: employer, deliveries_count: 1).count
      end

      test ".perform_for_medium_level DOES notify employer when application was read then canceled" do
        internship_application = create(:weekly_internship_application, :canceled_by_student)
        employer = internship_application.internship_offer.employer
        create(:internship_application_state_change,
               internship_application: internship_application,
               from_state: "submitted",
               to_state: "read_by_employer",
               author: employer)
        MailActionItem.delete_all

        item = MailActionItem.create!(
          recipient: employer,
          action_name: "canceled_internship_application_by_student",
          action_type: :pending_internship_application,
          internship_application:,
          urgency_level: :medium,
          stale_at: 30.days.from_now,
          resolved_at: nil,
          deliveries_count: 0,
          max_deliveries_count: 1
        )

        Services::EmployerActions::EmployerDigestMailer.perform_for_medium_level(user_id: employer.id)

        assert_equal [ item.id ],
                     MailActionItem.where(recipient: employer, deliveries_count: 1).pluck(:id)
      end

      test ".perform_for_medium_level does not re-send nor re-count an item already delivered to its max at a lower level" do
        employer = create(:employer)

        low_item = MailActionItem.create!(
          recipient: employer,
          action_name: "internship_offer_unpublished",
          action_type: :pending_internship_offer,
          urgency_level: :low,
          stale_at: 2.days.from_now,
          resolved_at: nil,
          deliveries_count: 1,
          max_deliveries_count: 1
        )

        medium_item = MailActionItem.create!(
          recipient: employer,
          action_name: "new_internship_application",
          action_type: :pending_internship_application,
          urgency_level: :medium,
          stale_at: 2.days.from_now,
          resolved_at: nil,
          deliveries_count: 0,
          max_deliveries_count: 2
        )

        Services::EmployerActions::EmployerDigestMailer.perform_for_medium_level(user_id: employer.id)

        assert_equal 1, low_item.reload.deliveries_count,
                     "an item already delivered to its max must not be re-sent nor re-counted"
        assert_equal 1, medium_item.reload.deliveries_count
      end
    end
  end
end
