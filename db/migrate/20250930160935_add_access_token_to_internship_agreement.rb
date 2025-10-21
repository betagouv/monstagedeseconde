class AddAccessTokenToInternshipAgreement < ActiveRecord::Migration[7.1]
  def up
    add_column :internship_agreements, :access_token, :string, null: true
    add_index :internship_agreements, :access_token, unique: true

  end

  def down
    remove_index :internship_agreements, :access_token
    remove_column :internship_agreements, :access_token
  end
end
