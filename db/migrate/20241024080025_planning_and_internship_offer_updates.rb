class PlanningAndInternshipOfferUpdates < ActiveRecord::Migration[7.1]
  def change
    remove_column :plannings, :weekly_lunch_break, :string
    remove_reference :plannings, :internship_occupation, index: true, foreign_key: true
    add_reference :plannings, :employer, foreign_key: { to_table: :users }
    add_column :plannings, :lunch_break, :string, limit: 250, null: true

    remove_column :internship_offers, :weekly_lunch_break, :string
    add_column :internship_offers, :entreprise_coordinates, :st_point, geographic: true
    add_index :internship_offers, :entreprise_coordinates, using: :gist
  end
end
