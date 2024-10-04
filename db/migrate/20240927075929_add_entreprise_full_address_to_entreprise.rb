class AddEntrepriseFullAddressToEntreprise < ActiveRecord::Migration[7.1]
  def up

    add_column :entreprises, :entreprise_full_address, :string, null: false, limit: 200

    remove_column :entreprises, :entreprise_street, :string
    remove_column :entreprises, :entreprise_zipcode, :string
    remove_column :entreprises, :entreprise_city, :string
    remove_column :entreprises, :manual_enter, :boolean

    rename_column :entreprises, :chosen_employer_name, :employer_chosen_name

    change_column_null :entreprises, :tutor_first_name, true
    change_column_null :entreprises, :tutor_last_name, true
    change_column_null :entreprises, :tutor_email, true
    change_column_null :entreprises, :tutor_phone, true
    change_column_null :entreprises, :tutor_function, true

    change_column :entreprises, :tutor_email, :string, limit: 80
    change_column :entreprises, :tutor_first_name, :string, limit: 60
    change_column :entreprises, :tutor_last_name, :string, limit: 60
    change_column :entreprises, :tutor_function, :string, limit: 150

    add_reference :entreprises, :sector, foreign_key: true, null: false
    add_column :entreprises, :updated_entreprise_full_address, :boolean, default: false
  end

  def down
    add_column :entreprises, :entreprise_zipcode, :string
    add_column :entreprises, :entreprise_city, :string
    add_column :entreprises, :manual_enter, :boolean

    rename_column :entreprises, :employer_chosen_name, :chosen_employer_name
    
    remove_column :entreprises, :entreprise_full_address, :string

    remove_reference :entreprises, :sector, foreign_key: true
    remove_column :entreprises, :updated_entreprise_full_address, :boolean

  end
end
