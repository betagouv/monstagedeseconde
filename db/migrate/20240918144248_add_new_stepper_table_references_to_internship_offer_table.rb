class AddNewStepperTableReferencesToInternshipOfferTable < ActiveRecord::Migration[7.1]
  def change
    add_reference :internship_offers, :internship_occupation,
                  foreign_key: true,
                  null: true
    add_reference :internship_offers, :entreprise,
                  foreign_key: true,
                  null: true
    add_reference :internship_offers, :planning,
                  foreign_key: true,
                  null: true
  end
end
