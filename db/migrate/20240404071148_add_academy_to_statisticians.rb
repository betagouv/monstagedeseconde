class AddAcademyToStatisticians < ActiveRecord::Migration[7.1]
  def change
    add_column :users, :academy_id, :integer
    add_column :users, :academy_region_id, :integer

    add_foreign_key :users, :academies, column: :academy_id
    add_foreign_key :users, :academy_regions, column: :academy_region_id

    add_index :users, :academy_id
    add_index :users, :academy_region_id
  end
end
