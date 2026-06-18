# frozen_string_literal: true

require "test_helper"

class MailActionConfigTest < ActiveSupport::TestCase
  test "config_for returns constant defaults when no record exists" do
    result = MailActionConfig.config_for("new_internship_application")
    assert_equal "medium", result[:urgency_level]
    assert_equal 2, result[:max_deliveries_count]
  end

  test "invalid urgency_level is rejected" do
    record = MailActionConfig.new(
      action_name: "new_internship_application",
      urgency_level: "ultra",
      max_deliveries_count: 2
    )
    assert_not record.valid?
    assert record.errors[:urgency_level].any?
  end

  test "invalid max_deliveries_count is rejected" do
    record = MailActionConfig.new(
      action_name: "new_internship_application",
      urgency_level: "medium",
      max_deliveries_count: 0
    )
    assert_not record.valid?
    assert record.errors[:max_deliveries_count].any?
  end

  test "config_for returns db values when a record exists" do
    MailActionConfig.create!(
      action_name: "new_internship_application",
      urgency_level: "critical",
      max_deliveries_count: 5
    )
    result = MailActionConfig.config_for("new_internship_application")
    assert_equal "critical", result[:urgency_level]
    assert_equal 5, result[:max_deliveries_count]
  end
end
