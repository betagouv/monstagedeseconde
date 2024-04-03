class AddAcademyToDepartments < ActiveRecord::Migration[7.1]
  def change
    add_column :departments, :academy_id, :integer
  end
end
