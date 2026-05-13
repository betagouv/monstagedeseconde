class CreateBoardingHouseViews < ActiveRecord::Migration[8.1]
  def change
    create_table :boarding_house_views do |t|
      t.references :boarding_house, null: false, foreign_key: true
      t.references :user, null: true, foreign_key: true
      t.float :latitude
      t.float :longitude
      t.integer :radius
      t.timestamps
    end
    add_index :boarding_house_views, :created_at
  end
end
