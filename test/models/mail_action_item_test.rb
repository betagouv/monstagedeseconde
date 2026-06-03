# frozen_string_literal: true

require "test_helper"

class MailActionItemTest < ActiveSupport::TestCase
  setup do
    @employer = create(:employer)
  end

  test ".create_by_name! raises ArgumentError for unknown name" do
    assert_raises(ArgumentError) do
      MailActionItem.create_by_name!("unknown_action", recipient: @employer)
    end
  end

  # Verify that each configured action builds correctly from ACTION_CONFIGS
  MailActionItem::ACTION_CONFIGS.each do |action_name, config|
    test ".create_by_name! with #{action_name} sets correct defaults" do
      freeze_time do
        item = MailActionItem.create_by_name!(action_name, recipient: @employer)
        assert item.persisted?, "expected record to be saved"
        assert_equal action_name, item.action_name
        assert_equal config[:action_type].to_s, item.action_type
        assert_equal config[:urgency_level], item.urgency_level
        assert_equal config[:max_deliveries_count], item.max_deliveries_count
      end
    end
  end

  test ".create_by_name! is idempotent: calling twice with same key returns the same record" do
    agreement = create(:internship_agreement)
    first  = MailActionItem.create_by_name!("agreement_to_sign", recipient: @employer, internship_agreement: agreement)
    second = MailActionItem.create_by_name!("agreement_to_sign", recipient: @employer, internship_agreement: agreement)
    assert_equal first.id, second.id
    assert_equal 1, MailActionItem.where(action_name: "agreement_to_sign",
                                         recipient: @employer,
                                         internship_agreement_id: agreement.id).count
  end

  test ".create_by_name! kwargs override default stale_at" do
    custom_stale_at = 14.days.from_now
    item = MailActionItem.create_by_name!(
      "new_internship_application",
      recipient: @employer,
      stale_at: custom_stale_at)
    assert_in_delta custom_stale_at, item.stale_at, 5.seconds
  end
end
