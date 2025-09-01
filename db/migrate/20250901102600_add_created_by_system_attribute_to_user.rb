class AddCreatedBySystemAttributeToUser < ActiveRecord::Migration[7.1]
  def change
    add_column :users, :created_by_system, :boolean, default: false, null: false
  end
end
