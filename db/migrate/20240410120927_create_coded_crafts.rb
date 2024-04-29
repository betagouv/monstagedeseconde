class CreateCodedCrafts < ActiveRecord::Migration[7.1]
  def change
    create_table :coded_crafts do |t|
      t.string :name, null: false, limit: 255
      t.integer :ogr_code, null: false, index: { unique: true }

      t.timestamps
    end
    add_reference :coded_crafts, :detailed_craft, null: false, foreign_key: true
  end
end
