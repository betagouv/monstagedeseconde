require "test_helper"

module Services
  module EmployerActions
    class DigestMailerTest < ActiveSupport::TestCase
      test ".purge_actions_for_user_and_level removes stale resolved and maxed" do
        employer = create(:employer)

        kept = MailActionItem.create!(
          user: employer,
          action_name: "new_internship_application",
          action_type: :pending_application,
          urgency_level: :medium,
          stale_at: 2.days.from_now,
          resolved_at: nil,
          deliveries_count: 0,
          max_deliveries_count: 1
        )

        MailActionItem.create!(
          user: employer,
          action_name: "new_internship_application",
          action_type: :pending_application,
          urgency_level: :medium,
          stale_at: 2.days.from_now,
          resolved_at: Time.current,
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
          deliveries_count: 0,
          max_deliveries_count: 1
        )

        MailActionItem.create!(
          user: employer,
          action_name: "new_internship_application",
          action_type: :pending_application,
          urgency_level: :medium,
          stale_at: 2.days.from_now,
          resolved_at: nil,
          deliveries_count: 2,
          max_deliveries_count: 1
        )

        Services::EmployerActions::DigestMailer.manage_actions_before_delivery(
          user_id: employer.id,
          urgency_level: "medium"
        )

        assert_equal [ kept.id ],
                     MailActionItem.where(user: employer).pluck(:id)
      end

      test "#find_actions filters out empty action groups" do
        item = Struct.new(:id).new(123)

        fake_actions = {
          "pending_application" => [ item ],
          "agreement_to_sign" => []
        }

        Services::EmployerActions::DigestBuilder.stub(
          :build_digest_by_user_and_urgency_level,
          fake_actions
        ) do
          result = Services::EmployerActions::DigestMailer.find_actions(
            user_id: 1,
            urgency_level: "medium"
          )
          assert_equal [ "pending_application" ], result.keys
        end
      end

      test "#find_actions returns empty array when digest is empty" do
        Services::EmployerActions::DigestBuilder.stub(
          :build_digest_by_user_and_urgency_level,
          {}
        ) do
          assert_equal [],
                       Services::EmployerActions::DigestMailer.find_actions(
                         user_id: 1,
                         urgency_level: "medium"
                       )
        end
      end
    end
  end
end
