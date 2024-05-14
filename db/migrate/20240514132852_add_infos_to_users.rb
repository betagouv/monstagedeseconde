class AddInfosToUsers < ActiveRecord::Migration[7.1]
  def change
    add_column :users, :address, :string
    add_column :users, :legal_representative_full_name, :string
    add_column :users, :legal_representative_email, :string
    add_column :users, :legal_representative_phone, :string
    add_column :internship_applications, :student_address, :string
    add_column :internship_applications, :student_legal_representative_full_name, :string
    add_column :internship_applications, :student_legal_representative_email, :string
    add_column :internship_applications, :student_legal_representative_phone, :string
  end
end
