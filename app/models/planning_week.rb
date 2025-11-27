
# frozen_string_literal: true

class PlanningWeek < ApplicationRecord
  include Weekable
  belongs_to :planning

  delegate :max_candidates, to: :planning
end