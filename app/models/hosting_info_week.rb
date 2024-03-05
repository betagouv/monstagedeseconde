# frozen_string_literal: true

class HostingInfoWeek < ApplicationRecord
  include Weekable
  belongs_to :hosting_info, counter_cache: true

  delegate :max_candidates, to: :hosting_info
end
