class RemoveContractLabelFromSchools < ActiveRecord::Migration[7.1]
  def change
    remove_column :schools, :contract_label, :string
  end
end
