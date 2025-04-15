class AddIndexToUser < ActiveRecord::Migration[7.1]
  def change
    add_index :users, :class_room_id
  end
end
