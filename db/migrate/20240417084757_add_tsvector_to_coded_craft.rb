class AddTsvectorToCodedCraft < ActiveRecord::Migration[7.1]
    def up
      add_column :coded_crafts, :search_tsv, :tsvector
      add_index :coded_crafts, :search_tsv, using: 'gin'
    end
  
    def down
      remove_index :coded_crafts, :search_tsv
      remove_column :coded_crafts, :search_tsv
    end
end
