# frozen_string_literal: true

# Stages partagés (MGF-1772) : chaque structure d'accueil accueille l'élève sur
# une période d'une semaine. Le coordinateur associe explicitement chaque structure
# à sa période (1 = semaine 1, 2 = semaine 2), ce qui détermine le date_range et le
# jeu d'horaires (P1/P2) de la convention correspondante.
class AddPeriodToCorporations < ActiveRecord::Migration[7.2]
  def change
    add_column :corporations, :period, :integer
  end
end
