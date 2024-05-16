class AddAddressToInternshipAgreement < ActiveRecord::Migration[7.1]
  def change
    add_column :internship_agreements, :internship_address, :string
    add_column :internship_agreements, :employer_name, :string
    add_column :internship_agreements, :employer_contact_email, :string
  end
end
