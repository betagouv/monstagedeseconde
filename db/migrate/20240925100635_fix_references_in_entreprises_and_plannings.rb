class FixReferencesInEntreprisesAndPlannings < ActiveRecord::Migration[7.1]
  def change
    remove_reference :entreprises, :internship_application, foreign_key: true
    remove_reference :plannings, :internship_applications, foreign_key: true

    add_column :internship_occupations, :internship_address_manual_enter, :boolean, default: false

    add_reference :entreprises, :internship_occupation, foreign_key: true
    add_reference :plannings, :internship_occupation, foreign_key: true

    change_column :internship_occupations, :description, :string, null: false, limit: 500
  end
end
