class RemoveMainTeacherFullNameFromInternshipAgreemts < ActiveRecord::Migration[7.1]
  def change
    remove_column :internship_agreements, :main_teacher_full_name
  end
end
