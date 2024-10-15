# TODO: remove if not mandatory
# require 'sti_preload'
class Planning < ApplicationRecord
  include StepperProxy::Planning
  # Relations

  belongs_to :entreprise
  # validates :weeks, presence: true
  # validate :enough_weeks
  # has_one :internship_offer
end
