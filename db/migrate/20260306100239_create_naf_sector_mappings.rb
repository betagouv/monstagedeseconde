class CreateNafSectorMappings < ActiveRecord::Migration[7.2]
  def change
    create_table :naf_sector_mappings do |t|
      t.string :code_naf
      t.references :sector, null: false, foreign_key: true
      t.date :date_start
      t.date :date_end

      t.timestamps
    end

    add_index :naf_sector_mappings, :code_naf
  end
end
