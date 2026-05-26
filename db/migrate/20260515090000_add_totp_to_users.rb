class AddTotpToUsers < ActiveRecord::Migration[7.2]
  def change
    add_column :users, :otp_secret, :string
    add_column :users, :otp_required_for_login, :boolean, default: false, null: false
    add_column :users, :otp_last_used_at, :datetime
  end
end
