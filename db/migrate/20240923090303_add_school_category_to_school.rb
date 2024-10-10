class AddSchoolCategoryToSchool < ActiveRecord::Migration[7.1]
  def up
    execute <<-SQL
      CREATE TYPE school_category AS ENUM ('college', 'lycee', 'college_lycee');
    SQL
    add_column :schools, :school_type, :school_category, default: 'college', null: false
  end

  def down
    remove_column :users, :school_type
    execute <<-SQL
      DROP TYPE school_category;
    SQL
  end
end
