class AddGradeToUsers < ActiveRecord::Migration[7.1]
  def change
    add_column :users, :grade, :string, limit: 100
    add_column :identities, :grade, :string, default: 'seconde', null: false, limit: 100
    add_column :schools, :level, :string, default: 'lycee', null: false, limit: 100
  end
end
