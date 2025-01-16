class RemoveTutorFromEntreprises < ActiveRecord::Migration[7.1]
  def change
    remove_column :entreprises, :tutor_email, :string
    remove_column :entreprises, :tutor_first_name, :string
    remove_column :entreprises, :tutor_last_name, :string
    remove_column :entreprises, :tutor_phone, :string
    remove_column :entreprises, :tutor_function, :string
  end
end
