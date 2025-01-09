
# frozen_string_literal: true

class PlanningWeek < ApplicationRecord
  include Weekable
  belongs_to :planning

  delegate :max_candidates, to: :planning
  delegate :max_students_per_group, to: :planning
end