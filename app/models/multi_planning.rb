class MultiPlanning < ApplicationRecord
  belongs_to :multi_coordinator
  belongs_to :school, optional: true

  validates :max_candidates, presence: true, numericality: { only_integer: true, greater_than: 0 }
  validates :weekly_hours, presence: true, length: { maximum: 400 }
  validates :lunch_break, presence: true, length: { maximum: 250 }
  validates :rep, inclusion: { in: [true, false] }
  validates :qpv, inclusion: { in: [true, false] }
end

