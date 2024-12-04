class AlterTableInternshipAgreements < ActiveRecord::Migration[7.1]
  def up
    change_column :internship_agreements, :tutor_role, :string, limit: 150
    change_column :internship_agreements, :organisation_representative_role, :string, limit: 150
    change_column :internship_agreements, :student_phone, :string, limit: 20
    change_column :internship_agreements, :school_representative_phone, :string, limit: 20
    change_column :internship_agreements, :student_refering_teacher_phone, :string, limit: 20
    change_column :internship_agreements, :student_legal_representative_email, :string, limit: 100
    change_column :internship_agreements, :student_refering_teacher_full_name, :string, limit: 100
    change_column :internship_agreements, :student_legal_representative_phone, :string, limit: 20
    change_column :internship_agreements, :student_legal_representative_2_full_name, :string, limit: 100
    change_column :internship_agreements, :student_legal_representative_2_email, :string, limit: 100
    change_column :internship_agreements, :student_legal_representative_2_phone, :string, limit: 20
    change_column :internship_agreements, :school_representative_role, :string, limit: 100
    change_column :internship_agreements, :school_representative_email, :string, limit: 100
  end

  def down
  end
end
