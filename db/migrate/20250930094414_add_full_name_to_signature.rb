class AddFullNameToSignature < ActiveRecord::Migration[7.1]
  def change
    add_column :signatures, :student_legal_representative_full_name, :string, limit: 150, null: false, default: ''
  end
end
