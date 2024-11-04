class RenameEntrepriseManualEnterIn < ActiveRecord::Migration[7.1]
  def change
    rename_column :internship_offers, :employer_manual_enter, :internship_address_manual_enter
  end
end
