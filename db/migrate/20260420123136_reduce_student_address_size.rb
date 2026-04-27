class ReduceStudentAddressSize < ActiveRecord::Migration[7.2]
  def change
    change_column :internship_agreements, :student_address, :string, limit: 170
  end
end
