class ChangeWeeklyHoursToMultiPlannings < ActiveRecord::Migration[7.1]
  def up
    # First, convert existing data if any (though likely empty or string)
    # We'll drop the column and recreate it as it's cleaner for dev/test environments and no production data yet
    remove_column :multi_plannings, :weekly_hours
    add_column :multi_plannings, :weekly_hours, :text, array: true, default: []
  end

  def down
    remove_column :multi_plannings, :weekly_hours
    add_column :multi_plannings, :weekly_hours, :text
  end
end

