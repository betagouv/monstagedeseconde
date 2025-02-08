class AddIneIndexToUser < ActiveRecord::Migration[7.1]
  def change
    add_index :users, :ine, unique: true
  end
end
