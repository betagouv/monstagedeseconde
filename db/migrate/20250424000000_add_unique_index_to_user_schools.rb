class AddUniqueIndexToUserSchools < ActiveRecord::Migration[7.1]
  def change
    add_index :user_schools, %i[user_id school_id], unique: true
  end
end
