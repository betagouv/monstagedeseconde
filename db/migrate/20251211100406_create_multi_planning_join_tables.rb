class CreateMultiPlanningJoinTables < ActiveRecord::Migration[7.1]
  def change
    create_table :multi_planning_grades do |t|
      t.references :multi_planning, null: false, foreign_key: true
      t.references :grade, null: false, foreign_key: true
      t.timestamps
    end

    create_table :multi_planning_reserved_schools do |t|
      t.references :multi_planning, null: false, foreign_key: true
      t.references :school, null: false, foreign_key: true
      t.timestamps
    end

    create_table :multi_planning_weeks do |t|
      t.references :multi_planning, null: false, foreign_key: true
      t.references :week, null: false, foreign_key: true
      t.timestamps
    end

    # Remove array columns that are replaced by join tables to avoid conflicts
    remove_column :multi_plannings, :grade_ids, :integer, array: true, default: []
    remove_column :multi_plannings, :week_ids, :integer, array: true, default: []
  end
end

