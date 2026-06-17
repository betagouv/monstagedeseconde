# frozen_string_literal: true

module SecondeLimitedPeriod
  extend ActiveSupport::Concern

  # Du lundi de la semaine de first_week jusqu'au 1er juillet :
  # seule la 2ème semaine de stage 2nde est proposable.
  def seconde_first_week_unavailable?
    today = Date.current
    today >= SchoolTrack::Seconde.first_monday && today < SchoolYear::Base.deposit_end_of_period
  end

  # Du lundi de la semaine de second_week jusqu'au 1er juillet :
  # duplication cachée, modification sans dates, création bloquée.
  def seconde_no_new_offers?
    today = Date.current
    today >= SchoolTrack::Seconde.last_monday && today < SchoolYear::Base.deposit_end_of_period
  end

  def seconde_no_new_offers_message
    "Le dépôt des offres pour la prochaine année scolaire sera ouvert à partir du 1er juillet."
  end
end
