# frozen_string_literal: true

# Stages partagés (MGF-1772) : avec 2 conventions par candidature (une par
# corporation), l'unicité (internship_application_id) seule n'est plus valable.
# On la remplace par deux index partiels :
#   - mono  : UNIQUE(internship_application_id) WHERE corporation_id IS NULL
#   - multi : UNIQUE(internship_application_id, corporation_id) WHERE corporation_id IS NOT NULL
# Postgres traitant chaque NULL comme distinct, il FAUT deux index séparés pour
# conserver l'unicité côté mono.
class ReplaceInternshipAgreementsUniqueIndexForCorporation < ActiveRecord::Migration[7.2]
  disable_ddl_transaction!

  def up
    remove_index :internship_agreements,
                 name: "index_internship_agreements_on_application_id_unique",
                 algorithm: :concurrently,
                 if_exists: true

    add_index :internship_agreements,
              :internship_application_id,
              unique: true,
              where: "discarded_at IS NULL AND corporation_id IS NULL",
              name: "index_ia_on_application_id_mono_unique",
              algorithm: :concurrently

    add_index :internship_agreements,
              %i[internship_application_id corporation_id],
              unique: true,
              where: "discarded_at IS NULL AND corporation_id IS NOT NULL",
              name: "index_ia_on_application_id_corporation_unique",
              algorithm: :concurrently
  end

  def down
    remove_index :internship_agreements,
                 name: "index_ia_on_application_id_mono_unique",
                 algorithm: :concurrently,
                 if_exists: true

    remove_index :internship_agreements,
                 name: "index_ia_on_application_id_corporation_unique",
                 algorithm: :concurrently,
                 if_exists: true

    add_index :internship_agreements,
              :internship_application_id,
              unique: true,
              where: "discarded_at IS NULL",
              name: "index_internship_agreements_on_application_id_unique",
              algorithm: :concurrently
  end
end
