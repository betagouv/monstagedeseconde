class AddPlanningWeek < ActiveRecord::Migration[7.1]
  def change
    create_table :planning_weeks do |t|
      t.references :planning, null: false, foreign_key: true
      t.references :week, null: false, foreign_key: true

      t.timestamps
    end
  end
end
