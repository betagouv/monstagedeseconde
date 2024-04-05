class RemoveOldDepartmentFromSchools < ActiveRecord::Migration[7.1]
  def change
    remove_column :schools, :department, :string
  end
end
