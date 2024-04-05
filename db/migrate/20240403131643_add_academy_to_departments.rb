class AddAcademyToDepartments < ActiveRecord::Migration[7.1]
  def change
    add_reference :departments, :academy, foreign_key: true, index: true
  end
end
