class RefactorCorporationFields < ActiveRecord::Migration[7.1]
  def change    
    rename_column :corporations, :phone, :employer_phone
    add_column :corporations, :employer_name, :string unless column_exists?(:corporations, :employer_name)
    add_column :corporations, :employer_role, :string unless column_exists?(:corporations, :employer_role)
    add_column :corporations, :employer_email, :string unless column_exists?(:corporations, :employer_email)
  end
end

