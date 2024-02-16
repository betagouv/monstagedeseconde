class ChangeRoleColumnTypeInUsers < ActiveRecord::Migration[7.1]
  def change
    change_column :users, :role, :string, using: 'role::text'
  end
end
