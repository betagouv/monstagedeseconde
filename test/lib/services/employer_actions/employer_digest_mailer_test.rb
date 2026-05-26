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

        Services::CommonActions::DigestBuilder.stub(
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
        Services::CommonActions::DigestBuilder.stub(
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

      test ".perform_for_medium_level delivers for canceled_internship_application_by_student" do
        internship_application = create(:weekly_internship_application)
        employer = internship_application.internship_offer.employer
        internship_application.update_columns(aasm_state: "canceled_by_student")
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

      test ".perform_for_medium_level delivers for restored_internship_application" do
        internship_application = create(:weekly_internship_application, :restored)
        employer = internship_application.internship_offer.employer
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
    end
  end
end
