class MultiCorporation < ApplicationRecord
  # Stage partagé : exactement 2 structures d'accueil (1 semaine chacune).
  MAX_CORPORATIONS = 2

  belongs_to :multi_coordinator
  has_many :corporations, dependent: :destroy
  has_one :internship_offer, foreign_key: :multi_corporation_id

  # Delegations
  delegate :coordinator, to: :multi_activity
  delegate :employer, to: :multi_coordinator

  # Les 2 structures sont renseignées : on bloque l'ajout et on invite à passer à la suite.
  def full?
    corporations.count >= MAX_CORPORATIONS
  end

  # Période (semaine) encore disponible pour la prochaine structure : 1 puis 2.
  def next_available_period
    ([1, 2] - corporations.pluck(:period).compact).first
  end
end


