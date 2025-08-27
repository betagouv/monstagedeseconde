class AddCodeApeToEnterpriseAndInternshipOffer < ActiveRecord::Migration[7.1]
  def change
    add_column :entreprises, :code_ape, :string
    add_column :internship_offers, :code_ape, :string
  end
end
