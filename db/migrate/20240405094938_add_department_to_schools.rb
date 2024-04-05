class AddDepartmentToSchools < ActiveRecord::Migration[7.1]
  def change
    add_reference :schools, :department, foreign_key: true, index: true
    TaskManager.new(
      allowed_environments: %w[development test review production staging],
      task_name: 'migrations:fullfill_schools_department',
      arguments: ['once_str, only_str']
    ).play_task_once(run_with_a_job: true)
  end
end
