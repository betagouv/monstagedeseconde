class RemoveDailyLunchBreak < ActiveRecord::Migration[7.1]
  def up
    remove_column :plannings, :daily_lunch_break, :jsonb, default: {}
    remove_column :internship_offers, :daily_lunch_break, :jsonb, default: {}
    remove_column :internship_agreements, :daily_lunch_break, :jsonb, default: {}
  end
end
