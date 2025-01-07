class AddRepAndQpvToInternshipOffers < ActiveRecord::Migration[7.1]
  def change
    add_column :internship_offers, :rep, :boolean, default: false
    add_column :internship_offers, :qpv, :boolean, default: false
    add_column :plannings, :rep, :boolean, default: false
    add_column :plannings, :qpv, :boolean, default: false
  end
end
