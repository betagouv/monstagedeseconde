class AddAcademyToDepartments < ActiveRecord::Migration[7.1]
  def change
    add_column :departments, :academy_id, :integer
    add_foreign_key :departments, :academies, column: :academy_id
    add_index :departments, :academy_id
  end
end
