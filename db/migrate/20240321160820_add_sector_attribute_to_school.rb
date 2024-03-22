class AddSectorAttributeToSchool < ActiveRecord::Migration[7.1]
  def change
    add_column :schools, :is_public, :boolean, default: true
    add_column :schools, :contract_code, :string, limit: 3
    add_column :schools, :contract_label, :string, limit: 70
  end
end
