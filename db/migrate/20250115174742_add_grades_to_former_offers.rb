class AddGradesToFormerOffers < ActiveRecord::Migration[7.1]
  def up
    # add a primary_key to the table task_registers
    # remove_column :task_registers, :id
    # add_column :task_registers, :id, :primary_key

    TaskManager.new(
      allowed_environments: %w[development review production staging],
      task_name: 'data_migrations:add_missing_grades_to_former_internship_offers',
      arguments: []
    ).play_task_each_time(run_with_a_job: false)
  end

  def down
  end
end
