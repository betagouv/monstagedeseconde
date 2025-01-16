class AddWorspaceConditionsToInternshipOffer < ActiveRecord::Migration[7.1]
  def change
    add_column :internship_offers, :workspace_conditions, :text, default: ''
    add_column :internship_offers, :workspace_accessibility, :text, default: ''
    add_column :entreprises, :workspace_conditions, :text, default: ''
    add_column :entreprises, :workspace_accessibility, :text, default: ''
  end
end
