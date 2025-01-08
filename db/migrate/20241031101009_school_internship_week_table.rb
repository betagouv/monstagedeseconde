class SchoolInternshipWeekTable < ActiveRecord::Migration[7.1]
  def change
    create_table :school_internship_weeks do |t|
      t.references :school, null: false, foreign_key: true
      t.references :week, null: false, foreign_key: true

      t.timestamps
    end
  end
end
