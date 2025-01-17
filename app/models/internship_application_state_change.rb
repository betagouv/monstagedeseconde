class InternshipApplicationStateChange < ApplicationRecord
  belongs_to :internship_application
  belongs_to :author, polymorphic: true, optional: true

  validates :to_state, presence: true
  validate :from_state_presence

  private

  def from_state_presence
    errors.add(:from_state, 'doit être présent') if from_state.blank? && to_state != 'submitted'
  end
end
