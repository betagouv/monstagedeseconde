class RemoveInternshipWeeksNumberFromInternshipOffers < ActiveRecord::Migration[7.1]
  def change
    remove_column :internship_offers, :internship_weeks_number, :integer, default: 1
  end
end
