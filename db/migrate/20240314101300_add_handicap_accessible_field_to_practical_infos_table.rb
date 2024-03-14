class AddHandicapAccessibleFieldToPracticalInfosTable < ActiveRecord::Migration[7.1]
  def change
    add_column :practical_infos, :handicap_accessible, :boolean, default: false, null: false
  end
end
