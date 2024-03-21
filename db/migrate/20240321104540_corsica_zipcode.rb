class CorsicaZipcode < ActiveRecord::Migration[7.1]
  def up
    create_table :corsica_zipcodes do |t|
      t.string :zipcode, limit: 5, null: false
      t.string :city, limit: 255, null: true
      t.string :department, limit: 255, null: true
      t.string :insee_code, null: false, limit: 5
      t.string :department_code, limit: 2, null: false

      t.index [ :zipcode ], unique: true
    end
  end
  def down
    drop_table :corsica_zipcodes
  end
end
