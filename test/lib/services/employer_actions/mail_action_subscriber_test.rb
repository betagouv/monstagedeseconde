require "test_helper"

module Services
  module EmployerActions
    class MailActionSubscriberTest < ActiveSupport::TestCase
      test "#mail_action_items_finder returns matching pending actions" do
        offer = create(:weekly_internship_offer_2nde)
        application = create(
          :weekly_internship_application,
          internship_offer: offer
        )

        expected_item = MailActionItem.create!(
          user: offer.employer,
          action_name: "new_internship_application",
          action_type: :pending_application,
          urgency_level: :medium,
          stale_at: 2.days.from_now,
          resolved_at: nil,
          payload: { internship_application_id: application.id },
          deliveries_count: 0,
          max_deliveries_count: 1
        )

        MailActionItem.create!(
          user: offer.employer,
          action_name: "new_internship_application",
          action_type: :pending_application,
          urgency_level: :medium,
          stale_at: 2.days.from_now,
          resolved_at: nil,
          payload: { internship_application_id: application.id + 1 },
          deliveries_count: 0,
          max_deliveries_count: 1
        )

        event = Struct.new(:name, :data).new(
          "internship_application.state_changed",
          { internship_application_id: application.id }
        )

        actions, found_application =
          Services::EmployerActions::MailActionSubscriber.new
            .send(:mail_action_items_finder, event)

        assert_equal application.id, found_application.id
        assert_includes actions.pluck(:id), expected_item.id
        assert_equal [ application.id ],
                     actions.map { |item| item.payload["internship_application_id"] }
                            .uniq
      end

      test "#mail_action_items_finder returns nil for unsupported event" do
        event = Struct.new(:name, :data).new(
          "internship_application.created",
          { internship_application_id: 1 }
        )

        result = Services::EmployerActions::MailActionSubscriber.new
                 .send(:mail_action_items_finder, event)

        assert_nil result
      end
    end
  end
end
