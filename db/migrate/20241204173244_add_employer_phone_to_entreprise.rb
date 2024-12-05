class AddEmployerPhoneToEntreprise < ActiveRecord::Migration[7.1]
  def change
    add_column :entreprises, :contact_phone, :string, limit: 20
  end
end
