class CreateBoardingHouses < ActiveRecord::Migration[7.2]
  def change
    create_table :boarding_houses do |t|
      t.string :name, null: false
      t.string :street
      t.string :zipcode, null: false
      t.string :city, null: false
      t.string :department, null: false
      t.string :contact_phone
      t.string :contact_email
      t.st_point :coordinates, geographic: true, srid: 4326
      t.integer :available_places, default: 0
      t.date :reference_date
      t.references :academy, foreign_key: true

      t.timestamps
    end

    add_index :boarding_houses, :coordinates, using: :gist
  end
end
