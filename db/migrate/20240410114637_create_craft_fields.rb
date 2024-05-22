class CreateCraftFields < ActiveRecord::Migration[7.1]
  def change
    create_table :craft_fields do |t|
      t.string :name, null: false, limit: 255
      t.string :letter, null: false, limit: 1, index: { unique: true }
    end
  end
end
