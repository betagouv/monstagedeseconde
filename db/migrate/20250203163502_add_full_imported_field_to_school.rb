class AddFullImportedFieldToSchool < ActiveRecord::Migration[7.1]
  def change
    add_column :schools, :full_imported, :boolean, default: false
  end
end
