class RemoveCreatedByTeacherFromUsers < ActiveRecord::Migration[7.1]
  def change
    remove_column :users, :created_by_teacher, :boolean
  end
end
