class AddLegalStatusToSchools < ActiveRecord::Migration[7.1]
  def change
    add_column :schools, :legal_status, :string
    add_column :internship_agreements, :legal_status, :string
  end
end
