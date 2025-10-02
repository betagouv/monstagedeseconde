class RemoveOldFieldFromInternshipAgreements < ActiveRecord::Migration[7.1]
  def up
    remove_column :internship_agreements, :school_delegation_to_sign_delivered_at
    remove_column :internship_agreements, :doc_date
  end

  def down
    add_column :internship_agreements, :school_delegation_to_sign_delivered_at, :datetime, null: true
    add_column :internship_agreements, :doc_date, :date, null: true
  end
end
