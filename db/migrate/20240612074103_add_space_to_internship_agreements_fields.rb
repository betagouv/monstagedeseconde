class AddSpaceToInternshipAgreementsFields < ActiveRecord::Migration[7.1]
  def change
    change_column  :internship_agreements, :tutor_role, :string, limit: 500
    change_column  :internship_agreements, :organisation_representative_role, :string, limit: 500
    change_column  :internship_agreements, :student_phone, :string, limit: 200
    change_column  :internship_agreements, :school_representative_phone, :string, limit: 100
    change_column  :internship_agreements, :student_refering_teacher_phone, :string, limit: 100
    change_column  :internship_agreements, :student_legal_representative_email, :string, limit: 180
    change_column  :internship_agreements, :student_refering_teacher_email, :string, limit: 100
    change_column  :internship_agreements, :student_legal_representative_full_name, :string, limit: 180
    change_column  :internship_agreements, :student_refering_teacher_full_name, :string, limit: 180
    change_column  :internship_agreements, :student_legal_representative_phone, :string, limit: 250
    change_column  :internship_agreements, :student_legal_representative_2_full_name, :string, limit: 180
    change_column  :internship_agreements, :student_legal_representative_2_email, :string, limit: 120
    change_column  :internship_agreements, :student_legal_representative_2_phone, :string, limit: 250
    change_column  :internship_agreements, :school_representative_role, :string, limit: 200
    change_column  :internship_agreements, :school_representative_email, :string, limit: 180
  end
end
