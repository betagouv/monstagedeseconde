class AddUniqueIndexOnInternshipAgreementsApplication < ActiveRecord::Migration[7.2]
  disable_ddl_transaction!

  def up
    discard_safe_duplicates
    fail_if_remaining_unsigned_duplicates_with_signatures

    remove_index :internship_agreements,
                 :internship_application_id,
                 name: "index_internship_agreements_on_internship_application_id",
                 algorithm: :concurrently,
                 if_exists: true

    add_index :internship_agreements,
              :internship_application_id,
              unique: true,
              where: "discarded_at IS NULL",
              name: "index_internship_agreements_on_application_id_unique",
              algorithm: :concurrently
  end

  def down
    remove_index :internship_agreements,
                 name: "index_internship_agreements_on_application_id_unique",
                 algorithm: :concurrently,
                 if_exists: true

    add_index :internship_agreements,
              :internship_application_id,
              name: "index_internship_agreements_on_internship_application_id",
              algorithm: :concurrently
  end

  private

  # Pour chaque application avec plusieurs conventions non discardées, on garde la "meilleure"
  # (le plus de signatures, à défaut la plus récente) et on discard les autres — uniquement
  # si elles n'ont AUCUNE signature (sinon on les laisse, ce qui fera échouer l'index UNIQUE
  # plus bas et forcera une revue manuelle).
  def discard_safe_duplicates
    say_with_time "Discarding safe duplicate internship_agreements" do
      execute(<<~SQL)
        WITH ranked AS (
          SELECT
            ia.id,
            ROW_NUMBER() OVER (
              PARTITION BY ia.internship_application_id
              ORDER BY
                (SELECT COUNT(*) FROM signatures s WHERE s.internship_agreement_id = ia.id) DESC,
                ia.created_at DESC
            ) AS rn,
            (SELECT COUNT(*) FROM signatures s WHERE s.internship_agreement_id = ia.id) AS sig_count
          FROM internship_agreements ia
          WHERE ia.discarded_at IS NULL
        )
        UPDATE internship_agreements
        SET discarded_at = NOW()
        FROM ranked
        WHERE internship_agreements.id = ranked.id
          AND ranked.rn > 1
          AND ranked.sig_count = 0
      SQL
    end
  end

  # Si après le nettoyage il reste des applications avec plusieurs conventions non discardées,
  # c'est qu'au moins deux sont signées : on refuse de discarder en aveugle. On lève une erreur
  # claire pour qu'un humain investigue.
  def fail_if_remaining_unsigned_duplicates_with_signatures
    rows = execute(<<~SQL).to_a
      SELECT internship_application_id, COUNT(*) AS n
      FROM internship_agreements
      WHERE discarded_at IS NULL
      GROUP BY internship_application_id
      HAVING COUNT(*) > 1
      ORDER BY internship_application_id
    SQL

    return if rows.empty?

    details = rows.map { |r| "  app##{r['internship_application_id']} (#{r['n']} agreements)" }.join("\n")
    raise ActiveRecord::IrreversibleMigration, <<~MSG
      Cannot create UNIQUE index : remaining duplicate internship_agreements
      for the following applications (each has multiple signed agreements) :

      #{details}

      Investiguer manuellement via la console avant de relancer la migration :
        rake retrofit:internship_agreements_dedoubling
    MSG
  end
end
