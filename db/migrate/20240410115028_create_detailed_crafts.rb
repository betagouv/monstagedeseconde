class CreateDetailedCrafts < ActiveRecord::Migration[7.1]
  def change
    create_table :detailed_crafts do |t|
      t.string :name, null: false, limit: 255
      t.string :number, null: false
      t.timestamps
    end
    add_reference :detailed_crafts, :craft, null: false, foreign_key: true
  end
end
