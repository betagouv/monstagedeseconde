class AddFimUserInfoToUsers < ActiveRecord::Migration[7.1]
  def change
    add_column :users, :fim_user_info, :jsonb
  end
end
