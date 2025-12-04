class RemoveCoordinatorFromInternshipAgreement < ActiveRecord::Migration[7.1]
  def change
    remove_reference :internship_agreements, :coordinator, foreign_key: { to_table: :users }
  end
end
