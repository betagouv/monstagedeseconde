class AddMainTeacherAcceptTermsToInternshipAgreements < ActiveRecord::Migration[6.0]
  def change
    add_column :internship_agreements, :teacher_accept_terms, :boolean, default: false
  end
end
