class AddIneToStudent < ActiveRecord::Migration[7.1]
  def change
    add_column :users, :ine, :string, null: true, limit: 15
    add_column :users, :active_at, :datetime, null: true
  end
end
