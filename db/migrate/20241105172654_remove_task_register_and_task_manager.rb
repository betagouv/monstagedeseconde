class RemoveTaskRegisterAndTaskManager < ActiveRecord::Migration[7.1]
  def up
    drop_table :task_registers
  end

  def down
  end
end
