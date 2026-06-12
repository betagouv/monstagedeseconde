require "test_helper"

module Services
  module CommonActions
    class DigestBuilderTest < ActiveSupport::TestCase
      test ".build_digest_by_user_and_urgency_level returns grouped actions" do
        employer = create(:employer)

        item = MailActionItem.create!(
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

        digest = Services::CommonActions::DigestBuilder
                 .build_digest_by_user_and_urgency_level(
                   user_id: employer.id,
                   urgency_levels: [ "medium" ]
                 )

        assert_equal [ item.id ], digest["pending_internship_application"].map(&:id)
      end

      test ".build_digest_by_user_and_urgency_level returns empty hash" do
        employer = create(:employer)

        digest = Services::CommonActions::DigestBuilder
                 .build_digest_by_user_and_urgency_level(
                   user_id: employer.id,
                   urgency_levels: [ "high" ]
                 )

        assert_equal({}, digest)
      end
    end
  end
end
