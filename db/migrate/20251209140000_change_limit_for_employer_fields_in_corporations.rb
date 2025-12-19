class ChangeLimitForEmployerFieldsInCorporations < ActiveRecord::Migration[7.1]
  def change
    change_column :corporations, :employer_email, :string, limit: 120
    change_column :corporations, :employer_role, :string, limit: 120
  end
end

