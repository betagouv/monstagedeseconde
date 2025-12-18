class CreateCorporationInternshipAgreements < ActiveRecord::Migration[7.1]
  def change
    create_table :corporation_internship_agreements do |t|
      t.references :corporation, null: false, foreign_key: true
      t.references :internship_agreement, null: false, foreign_key: true
      t.boolean :signed, default: false, null: false

      t.timestamps
    end
  end
end
