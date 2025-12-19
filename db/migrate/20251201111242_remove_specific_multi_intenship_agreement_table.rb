class RemoveSpecificMultiIntenshipAgreementTable < ActiveRecord::Migration[7.1]
  def up
    drop_table :multi_internship_agreements, if_exists: true
    add_reference :internship_agreements, :coordinator, foreign_key: { to_table: :users }
    add_column :internship_agreements, :type, :string, null: false, default: 'InternshipAgreements::MonoInternshipAgreement'
  end

  def down
    remove_column :internship_agreements, :type
    remove_reference :internship_agreements, :coordinator, foreign_key: { to_table: :users }
  end
end
