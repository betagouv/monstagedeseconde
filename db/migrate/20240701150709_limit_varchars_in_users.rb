class LimitVarcharsInUsers < ActiveRecord::Migration[7.1]
  def up
    change_column :users, :encrypted_password, :string, limit: 60
    change_column :users, :reset_password_token, :string, limit: 64
    change_column :users, :current_sign_in_ip, :string, limit: 15
    change_column :users, :last_sign_in_ip, :string, limit: 15
    change_column :users, :confirmation_token, :string, limit: 20
    change_column :users, :unconfirmed_email, :string, limit: 70
    change_column :users, :phone, :string, limit: 20
    change_column :users, :first_name, :string, limit: 85
    change_column :users, :last_name, :string, limit: 85
    change_column :users, :operator_name, :string, limit: 50
    change_column :users, :type, :string, limit: 50
    change_column :users, :gender, :string, limit: 2
    change_column :users, :api_token, :string, limit: 36
    change_column :users, :department, :string, limit: 2
    change_column :users, :role, :string, limit: 50
    change_column :users, :phone_token, :string, limit: 4
    change_column :users, :signature_phone_token, :string, limit: 10
    change_column :users, :employer_role, :string, limit: 150
    change_column :users, :hubspot_id, :string, limit: 15
    change_column :users, :address, :string, limit: 300
    change_column :users, :legal_representative_full_name, :string, limit: 100
    change_column :users, :legal_representative_email, :string, limit: 109
    change_column :users, :legal_representative_phone, :string, limit: 50
    change_column :users, :unlock_token, :string, limit: 64
    change_column :users, :email, :string, limit: 70
  end

  def down
  end
end
