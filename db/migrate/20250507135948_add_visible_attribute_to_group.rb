class AddVisibleAttributeToGroup < ActiveRecord::Migration[7.1]
  def change
    add_column :groups, :visible, :boolean, default: true
    add_index :groups, :visible
  end
end
