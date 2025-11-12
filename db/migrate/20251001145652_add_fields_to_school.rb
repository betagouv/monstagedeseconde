class AddFieldsToSchool < ActiveRecord::Migration[7.1]
  def up
    remove_column :schools, :fetched_school_phone
    remove_column :schools, :fetched_school_address
    remove_column :schools, :fetched_school_email

    add_column :schools, :contact_phone, :string, limit: 20, null: true
    add_column :schools, :contact_email, :string, limit: 120, null: true
    add_column :schools, :web, :string, limit: 255, null: true
    add_column :schools, :code_nature, :string, limit: 3, null: true
    add_column :schools, :code_type_contrat_prive, :string, limit: 100, null: true
    add_column :schools, :ministere_tutelle, :string, limit: 80, null: true
    add_column :schools, :lycee_des_metiers, :boolean, null: true
    add_column :schools, :lycee_militaire, :boolean, null: true
    add_column :schools, :lycee_agricole, :boolean, null: true
    add_column :schools, :segpa, :boolean, null: true
  end

  def down
    add_column :schools, :fetched_school_phone, :string, limit: 20, null: true
    add_column :schools, :fetched_school_address, :string, limit: 255, null: true
    add_column :schools, :fetched_school_email, :string, limit: 120, null: true

    remove_column :schools, :contact_phone
    remove_column :schools, :contact_email
    remove_column :schools, :web
    remove_column :schools, :code_nature
    remove_column :schools, :code_type_contrat_prive
    remove_column :schools, :ministere_tutelle
    remove_column :schools, :lycee_des_metiers
    remove_column :schools, :lycee_militaire
    remove_column :schools, :lycee_agricole
    remove_column :schools, :segpa
  end
end
