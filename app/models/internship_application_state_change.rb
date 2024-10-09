class InternshipApplicationStateChange < ApplicationRecord
  belongs_to :internship_application
  belongs_to :author, polymorphic: true, optional: true

  validates :from_state, :to_state, presence: true
end
