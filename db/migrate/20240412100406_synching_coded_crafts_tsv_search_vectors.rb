class SynchingCodedCraftsTsvSearchVectors < ActiveRecord::Migration[7.1]
def up
    execute <<-SQL
      DROP TRIGGER IF EXISTS sync_coded_craft_name_tsv
      ON coded_crafts
    SQL

    execute <<-SQL
      DROP TEXT SEARCH CONFIGURATION IF EXISTS fr
    SQL

    execute <<-SQL
      CREATE TEXT SEARCH CONFIGURATION fr ( COPY = french );
      ALTER TEXT SEARCH CONFIGURATION fr
      ALTER MAPPING FOR hword, hword_part, word
      WITH unaccent, french_stem;
    SQL

    execute <<-SQL
      CREATE TRIGGER sync_coded_craft_name_tsv BEFORE INSERT OR UPDATE
        ON coded_crafts FOR EACH ROW EXECUTE PROCEDURE
        tsvector_update_trigger(name_tsv, 'public.fr', name);
    SQL

  end

  def down
    execute <<-SQL
      DROP TRIGGER IF EXISTS sync_coded_craft_name_tsv
      ON coded_crafts
    SQL

    execute <<-SQL
      DROP TEXT SEARCH CONFIGURATION IF EXISTS fr
    SQL
  end
end
