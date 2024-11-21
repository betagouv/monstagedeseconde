class CreatePlanningGradesTable < ActiveRecord::Migration[7.1]
  def up
    create_table :planning_grades do |t|
      t.references :grade, null: false, foreign_key: true
      t.references :planning, null: false, foreign_key: true

      t.timestamps
    end

    drop_table :internship_offer_grades, if_exists: true

    create_table :internship_offer_grades do |t|
      t.references :grade, null: false, foreign_key: true
      t.references :internship_offer, null: false, foreign_key: true

      t.timestamps
    end
  end

  def down
    drop_table :internship_offer_grades if table_exists?(:internship_offer_grades)
    drop_table :planning_grades if table_exists?(:planning_grades)
    drop_table :plannig_grades if table_exists?(:plannig_grades)
  end
end
