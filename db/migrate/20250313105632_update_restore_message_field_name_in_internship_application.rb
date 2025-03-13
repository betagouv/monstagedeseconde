class UpdateRestoreMessageFieldNameInInternshipApplication < ActiveRecord::Migration[7.1]
  def change
    rename_column :internship_applications, :restore_message, :restored_message if column_exists?(
      :internship_applications, :restore_message
    )
    # Ex:- rename_column("admin_users", "pasword","hashed_pasword")
  end
end
