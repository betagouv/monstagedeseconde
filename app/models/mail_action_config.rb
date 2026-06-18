# frozen_string_literal: true

class MailActionConfig < ApplicationRecord
  include MailActionConfigurable

  URGENCY_LEVELS = %w[low medium high critical].freeze

  validates :action_name,
            presence: true,
            uniqueness: true
  validates :urgency_level,
            inclusion: { in: URGENCY_LEVELS }
  validates :max_deliveries_count,
            numericality: {
              only_integer: true,
              greater_than_or_equal_to: 1,
              less_than_or_equal_to: 10
            }

  def self.config_for(action_name)
    record = find_by(action_name: action_name)
    return db_config(record) if record

    constant_config(action_name)
  end

  private

  def self.db_config(record)
    {
      urgency_level: record.urgency_level,
      max_deliveries_count: record.max_deliveries_count
    }
  end

  def self.constant_config(action_name)
    defaults = ACTION_CONFIGS[action_name]
    {
      urgency_level: defaults[:urgency_level],
      max_deliveries_count: defaults[:max_deliveries_count]
    }
  end
end
