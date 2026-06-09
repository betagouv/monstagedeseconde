# frozen_string_literal: true

# Snapshot hebdomadaire du taux de pénétration de la plate-forme pour un établissement.
# Une entrée par établissement et par date de référence (cf. CreateSchoolStats).
class SchoolStat < ApplicationRecord
  belongs_to :school

  validates :date_reference, presence: true
  validates :school_id, presence: true

  scope :latest, -> { order(date_reference: :desc) }
  scope :on, ->(date) { where(date_reference: date) }
end
