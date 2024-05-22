class CreateCrafts < ActiveRecord::Migration[7.1]
  def change
    create_table :crafts do |t|
      t.string :name, null: false, limit: 255
      t.string :number, null: false
    end
    add_reference :crafts, :craft_field, null: false, foreign_key: true
  end
end
