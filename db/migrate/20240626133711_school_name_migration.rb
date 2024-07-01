class SchoolNameMigration < ActiveRecord::Migration[7.1]
  def up
    change_column :internship_agreements, :student_school, :string, limit: 150
  end
  
  def down
    change_column :internship_agreements, :student_school, :string, limit: 100
  end
end
