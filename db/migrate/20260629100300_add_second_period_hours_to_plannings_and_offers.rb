# frozen_string_literal: true

# Stages partagés (MGF-1772) : sur un stage de 2 x 1 semaine, le coordinateur peut
# saisir des horaires différents pour la seconde période. On stocke un second jeu
# d'horaires (journaliers + hebdomadaires) en plus du jeu existant (période 1), sur
# le planning multi et sur l'offre publiée.
class AddSecondPeriodHoursToPlanningsAndOffers < ActiveRecord::Migration[7.2]
  def change
    add_column :multi_plannings, :daily_hours_2, :jsonb, default: {}
    add_column :multi_plannings, :weekly_hours_2, :text, array: true, default: []

    add_column :internship_offers, :daily_hours_2, :jsonb, default: {}
    add_column :internship_offers, :weekly_hours_2, :text, array: true, default: []
  end
end
