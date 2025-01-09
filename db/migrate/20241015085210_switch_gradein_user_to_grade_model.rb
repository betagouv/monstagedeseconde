class SwitchGradeinUserToGradeModel < ActiveRecord::Migration[7.1]
  def up
    remove_column :users, :grade, :string
    add_reference :users, :grade, foreign_key: true

    remove_column :class_rooms, :grade, :string, if_exists: true
    add_reference :class_rooms, :grade, foreign_key: true
  end

  def down
    remove_reference :users, :grade, foreign_key: true
    add_column :users, :grade, :string

    remove_reference :class_rooms, :grade, foreign_key: true
    add_column :class_rooms, :grade, :string, defaut: '3e'
  end
end
