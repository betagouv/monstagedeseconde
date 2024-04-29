class CreateSiretBases < ActiveRecord::Migration[7.1]
  def change
    create_table :siret_bases do |t|
      t.string :siret, limit: 14
      t.date :last_activity

      t.timestamps
    end
    add_index :siret_bases, :siret
  end
end
