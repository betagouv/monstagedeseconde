class AddEntrepriseAddressToAgreements < ActiveRecord::Migration[7.1]
  def change
    add_column :internship_agreements, :entreprise_address, :string
    add_column :internship_agreements, :student_birth_date, :date
    add_column :internship_agreements, :pai_project, :boolean
    add_column :internship_agreements, :pai_trousse_family, :boolean
  end
end
