class UpdateFieldNameInInternshipAgreement < ActiveRecord::Migration[7.1]
  def change
    rename_column :internship_agreements, :main_teacher_accept_terms, :teacher_accept_terms
  end
end
