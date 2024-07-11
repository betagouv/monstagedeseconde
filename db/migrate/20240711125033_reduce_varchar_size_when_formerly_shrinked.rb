class ReduceVarcharSizeWhenFormerlyShrinked < ActiveRecord::Migration[7.1]
  def up
    change_column :internship_agreements, :date_range, :string, limit: 70
    change_column :internship_agreements, :tutor_full_name, :string, limit: 120
    change_column :internship_agreements, :siret, :string, limit: 14
    change_column :internship_agreements, :tutor_role, :string, limit: 200
    change_column :internship_agreements, :organisation_representative_role, :string, limit: 250
    change_column :internship_agreements, :student_phone, :string, limit: 20
    change_column :internship_agreements, :school_representative_phone, :string, limit: 20
    change_column :internship_agreements, :student_refering_teacher_phone, :string, limit: 20
    change_column :internship_agreements, :student_refering_teacher_email, :string, limit: 100
    change_column :internship_agreements, :student_legal_representative_phone, :string, limit: 100
    change_column :internship_agreements, :student_legal_representative_2_full_name, :string, limit: 120
    change_column :internship_agreements, :student_legal_representative_2_email, :string, limit: 100
    change_column :internship_agreements, :student_legal_representative_2_phone, :string, limit: 20
    change_column :internship_agreements, :school_representative_email, :string, limit: 100

    change_column :internship_applications, :student_legal_representative_email, :string, limit: 100
    change_column :internship_applications, :student_legal_representative_phone, :string, limit: 20

    change_column :internship_offers, :title, :string, limit: 150
    change_column :internship_offers, :tutor_name, :string, limit: 120
    change_column :internship_offers, :employer_website, :string, limit: 300
    change_column :internship_offers, :street, :string, limit: 400

    change_column :organisations, :employer_website, :string, limit: 300

    change_column :users, :legal_representative_email, :string, limit: 100
    change_column :users, :legal_representative_phone, :string, limit: 20

    change_column :users_search_histories, :city, :string, limit: 50
  end

  def down
  end
end
