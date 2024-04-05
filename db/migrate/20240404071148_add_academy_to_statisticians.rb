class AddAcademyToStatisticians < ActiveRecord::Migration[7.1]
  def change
    add_reference :users, :academy, foreign_key: true, index: true
    add_reference :users, :academy_region, foreign_key: true, index: true
  end
end
