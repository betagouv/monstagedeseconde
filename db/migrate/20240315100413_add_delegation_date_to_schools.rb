class AddDelegationDateToSchools < ActiveRecord::Migration[7.1]
  def change
    add_column :schools, :delegation_date, :date
    add_column :internship_agreements, :delegation_date, :date
  end
end
