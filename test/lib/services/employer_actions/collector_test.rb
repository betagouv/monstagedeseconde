require "test_helper"

module Services
  module EmployerActions
    class CollectorTest < ActiveSupport::TestCase
      test ".perform_for_user returns digest hash keyed by user id" do
        employer = create(:employer)

        MailActionItem.create!(
          user: employer,
          action_name: "new_internship_application",
          action_type: :pending_application,
          urgency_level: :medium,
          stale_at: 2.days.from_now,
          resolved_at: nil,
          payload: {},
          deliveries_count: 0,
          max_deliveries_count: 1
        )

        result = Services::EmployerActions::Collector.perform_for_user(
          user_id: employer.id
        )

        assert_equal [ employer.id ], result.keys
        assert_equal [ "medium" ], result[employer.id].keys
      end

      test ".perform returns one digest per involved user" do
        first_employer = create(:employer)
        second_employer = create(:employer)

        [ first_employer, second_employer ].each do |employer|
          MailActionItem.create!(
            user: employer,
            action_name: "new_internship_application",
            action_type: :pending_application,
            urgency_level: :medium,
            stale_at: 2.days.from_now,
            resolved_at: nil,
            payload: {},
            deliveries_count: 0,
            max_deliveries_count: 1
          )
        end

        result = Services::EmployerActions::Collector.perform

        assert_equal 2, result.size
        assert_equal [ first_employer.id, second_employer.id ].sort,
                     result.map(&:keys).flatten.sort
      end
    end
  end
end
