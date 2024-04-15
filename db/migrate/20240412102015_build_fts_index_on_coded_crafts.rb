class BuildFtsIndexOnCodedCrafts < ActiveRecord::Migration[7.1]
  def up
    execute <<-SQL
      CREATE TRIGGER sync_coded_crafts_tsv BEFORE INSERT OR UPDATE
        ON coded_crafts FOR EACH ROW EXECUTE PROCEDURE
        tsvector_update_trigger(name_tsv, 'public.fr', name);
    SQL
  end

  def down
    execute <<-SQL
      DROP TRIGGER IF EXISTS sync_coded_crafts_tsv
      ON coded_crafts
    SQL
  end
end
