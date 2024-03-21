class AddClassSizeToClassRoom < ActiveRecord::Migration[7.1]
  def change
    add_column :class_rooms, :class_size, :integer
  end
end
