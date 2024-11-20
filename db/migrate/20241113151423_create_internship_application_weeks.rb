class CreateInternshipApplicationWeeks < ActiveRecord::Migration[7.1]
  def change
    create_table :internship_application_weeks do |t|
      t.references :week, null: false, foreign_key: true
      t.references :internship_application, null: false, foreign_key: true

      t.timestamps
    end
  end
end
