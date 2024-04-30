class AddMaskedDataAttributeToOperator < ActiveRecord::Migration[7.1]
  def change
    add_column :operators, :masked_data, :boolean, default: false
  end
end
