class AddFieldsToInternshipOffer < ActiveRecord::Migration[7.1]
  def up
    add_column :internship_offers, :employer_chosen_name, :string, limit: 250
    add_column :internship_offers, :entreprise_coordinates, :point
    add_column :internship_offers, :tutor_function, :string, limit: 150
    add_column :internship_offers, :tutor_last_name, :string, limit: 60
    add_column :internship_offers, :tutor_first_name, :string, limit: 60
    add_column :internship_offers, :entreprise_full_address, :string, limit: 200

    remove_column :plannings, :weeks_count
  end

  def down
    remove_column :internship_offers, :employer_chosen_name
    remove_column :internship_offers, :entreprise_coordinates
    remove_column :internship_offers, :tutor_function
    remove_column :internship_offers, :tutor_last_name
    remove_column :internship_offers, :tutor_first_name
    remove_column :internship_offers, :entreprise_full_address
  end
end
