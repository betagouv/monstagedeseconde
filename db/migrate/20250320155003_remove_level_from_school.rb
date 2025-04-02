class RemoveLevelFromSchool < ActiveRecord::Migration[7.1]
  def change
    remove_column :schools, :level, :string, null: false, default: 'college'
  end
end
