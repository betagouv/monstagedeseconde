class UpdateEmployerNameLengthInternshipOffer < ActiveRecord::Migration[7.1]
  def up
    change_column :internship_offers, :employer_name, :string, limit: 150
    change_column :internship_offers, :employer_chosen_name, :string, limit: 150
    change_column :entreprises, :employer_name, :string, limit: 150
    change_column :entreprises, :employer_chosen_name, :string, limit: 150
  end

  def down
  end
end
