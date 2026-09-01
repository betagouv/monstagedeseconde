# frozen_string_literal: true

# Stages partagés (MGF-1772) : une candidature retenue débouche sur 2 conventions
# distinctes, une par structure d'accueil (Corporation). On rattache donc chaque
# convention à sa structure. Nullable : les conventions mono et les multi historiques
# n'ont pas de corporation_id.
class AddCorporationToInternshipAgreements < ActiveRecord::Migration[7.2]
  def change
    add_reference :internship_agreements, :corporation, foreign_key: true, null: true
  end
end
