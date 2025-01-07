class AddinternshipAddressManualEnterToEntreprise < ActiveRecord::Migration[7.1]
  def change
    add_column :entreprises, :internship_address_manual_enter, :boolean, default: false
    remove_column :internship_occupations, :internship_address_manual_enter, :boolean
  end
end
