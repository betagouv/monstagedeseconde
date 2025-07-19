class AddReservedSchoolsTable < ActiveRecord::Migration[7.1]
  def change
    create_table :planning_reserved_schools do |t|
      t.references :planning, null: false, foreign_key: true
      t.references :school, null: false, foreign_key: true
      t.timestamps
    end

    create_table :reserved_schools do |t|
      t.references :internship_offer, null: false, foreign_key: true
      t.references :school, null: false, foreign_key: true
      t.timestamps
    end
  end
end
