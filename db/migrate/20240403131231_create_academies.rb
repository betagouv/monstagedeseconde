class CreateAcademies < ActiveRecord::Migration[7.1]
  def change
    create_table :academies do |t|
      t.string :name
      t.string :email_domain
      t.integer :academy_region_id

      t.timestamps
    end
  end
end
