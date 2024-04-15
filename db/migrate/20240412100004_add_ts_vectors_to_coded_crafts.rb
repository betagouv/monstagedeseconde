class AddTsVectorsToCodedCrafts < ActiveRecord::Migration[7.1]
  def change
    add_column :coded_crafts, :name_tsv, :tsvector
    add_index :coded_crafts, :name_tsv, using: 'gin'
  end
end
