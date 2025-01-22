class PeriodAreNowWeeks < ActiveRecord::Migration[7.1]
  def up
    unless column_exists?(:internship_offers, :period)
      add_column :internship_offers, :period, :integer, default: 0, null: false
    end
    TaskManager.new(
      allowed_environments: %w[development review staging production],
      task_name: 'data_migrations:offers_format_update'
    ).play_task_each_time # will be run as a job
  end

  def down
  end
end
