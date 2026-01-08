class RemoveWeeklyLunchBreakField < ActiveRecord::Migration[7.1]
  def up
    remove_column :internship_agreements, :weekly_lunch_break, :text
  end

  def down
    add_column :internship_agreements, :weekly_lunch_break, :text
  end
end
