class AddPreSelectedForSignatureToInternshipAgreement < ActiveRecord::Migration[7.2]
  def change
    add_column :internship_agreements, :pre_selected_for_signature, :boolean, default: false, null: false
  end
end
