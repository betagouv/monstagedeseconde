require "test_helper"

module Services
  module EmployerActions
    class ActionListTest < ActiveSupport::TestCase
      test "#by_levels groups only pending not overdue actions by urgency" do
        employer = create(:employer)

        valid_medium = MailActionItem.create!(
          recipient: employer,
          action_name: "new_internship_application",
          action_type: :pending_internship_application,
          urgency_level: :medium,
          stale_at: 2.days.from_now,
          resolved_at: nil,
          payload: {},
          deliveries_count: 0,
          max_deliveries_count: 1
        )

        MailActionItem.create!(
          recipient: employer,
          action_name: "new_internship_application",
          action_type: :pending_internship_application,
          urgency_level: :medium,
          stale_at: 1.day.ago,
          resolved_at: nil,
          payload: {},
          deliveries_count: 0,
          max_deliveries_count: 1
        )

        MailActionItem.create!(
          recipient: employer,
          action_name: "new_internship_application",
          action_type: :pending_internship_application,
          urgency_level: :medium,
          stale_at: 2.days.from_now,
          resolved_at: Time.current,
          payload: {},
          deliveries_count: 0,
          max_deliveries_count: 1
        )

        valid_low = MailActionItem.create!(
          recipient: employer,
          action_name: "new_internship_application",
          action_type: :pending_internship_application,
          urgency_level: :low,
          stale_at: 2.days.from_now,
          resolved_at: nil,
          payload: {},
          deliveries_count: 0,
          max_deliveries_count: 1
        )

        list = Services::EmployerActions::ActionList.new(user_id: employer.id)

        by_levels = list.by_levels

        assert_equal [ valid_medium.id ],
                     by_levels["medium"]["pending_internship_application"].map(&:id)
        assert_equal [ valid_low.id ],
                     by_levels["low"]["pending_internship_application"].map(&:id)
      end

      test "#by_urgency_level returns empty hash when no actions exist for levels" do
        employer = create(:employer)
        list = Services::EmployerActions::ActionList.new(user_id: employer.id)

        assert_equal({}, list.by_urgency_level(urgency_levels: [ "critical" ]))
      end

      test "#by_urgency_level merges actions for multiple urgency levels" do
        employer = create(:employer)

        medium_item = MailActionItem.create!(
          recipient: employer,
          action_name: "new_internship_application",
          action_type: :pending_internship_application,
          urgency_level: :medium,
          stale_at: 2.days.from_now,
          resolved_at: nil,
          payload: {},
          deliveries_count: 0,
          max_deliveries_count: 1
        )

        low_item = MailActionItem.create!(
          recipient: employer,
          action_name: "new_internship_application",
          action_type: :pending_internship_application,
          urgency_level: :low,
          stale_at: 2.days.from_now,
          resolved_at: nil,
          payload: {},
          deliveries_count: 0,
          max_deliveries_count: 1
        )

        list = Services::EmployerActions::ActionList.new(user_id: employer.id)

        by_urgency = list.by_urgency_level(urgency_levels: [ "medium", "low" ])

        assert_equal [ medium_item.id, low_item.id ].sort,
                     by_urgency["pending_internship_application"].map(&:id).sort
      end
    end
  end
end
