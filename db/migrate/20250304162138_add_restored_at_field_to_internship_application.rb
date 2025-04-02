class AddRestoredAtFieldToInternshipApplication < ActiveRecord::Migration[7.1]
  def change
    add_column :internship_applications, :restored_at, :datetime, null: true
    add_column :internship_applications, :restored_message, :text, null: true
  end
end
