class AddMultiPlanningsFields < ActiveRecord::Migration[7.1]
  def change
    add_column :multi_plannings, :week_ids, :integer, array: true, default: []
    add_column :multi_plannings, :grade_ids, :integer, array: true, default: []
  end
end


