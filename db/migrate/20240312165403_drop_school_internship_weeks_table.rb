class DropSchoolInternshipWeeksTable < ActiveRecord::Migration[7.1]
  def up
    drop_table :school_internship_weeks
  end

  def down
    create_table :school_internship_weeks do |t|
      t.belongs_to :school, foreign_key: true
      t.belongs_to :week, foreign_key: true

      t.timestamps
    end
  end
end
