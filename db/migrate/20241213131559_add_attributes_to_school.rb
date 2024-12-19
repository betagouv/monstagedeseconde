class AddAttributesToSchool < ActiveRecord::Migration[7.1]
  def change
    add_column :schools, :voie_generale, :boolean, null: true
    add_column :schools, :voie_techno, :boolean, null: true
  end
end
