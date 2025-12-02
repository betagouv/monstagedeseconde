class CreateMultiPlannings < ActiveRecord::Migration[7.1]
  def change
    create_table :multi_plannings do |t|
      t.integer :max_candidates, null: false
      t.integer :remaining_seats_count
      t.string :weekly_hours, limit: 400, null: false
      t.jsonb :daily_hours
      t.string :lunch_break, limit: 250, null: false
      
      t.references :multi_coordinator, null: false, foreign_key: true
      t.references :school, foreign_key: true
      
      t.boolean :rep, null: false, default: false
      t.boolean :qpv, null: false, default: false

      t.timestamps
    end
  end
end

