class AddMultiCorporationReferenceToInternshipOffer < ActiveRecord::Migration[7.1]
  def change
    add_reference :internship_offers, :multi_corporation, foreign_key: true, null: true
  end
end
