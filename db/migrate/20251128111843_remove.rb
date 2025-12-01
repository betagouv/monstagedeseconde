class Remove < ActiveRecord::Migration[7.1]
  def up
    remove_column :internship_agreements, :school_manager_accept_terms, :boolean
    remove_column :internship_agreements, :employer_accept_terms, :boolean
    remove_column :internship_agreements, :teacher_accept_terms, :boolean
  end

  def down
    add_column :internship_agreements, :school_manager_accept_terms, :boolean, default: false, null: false
    add_column :internship_agreements, :employer_accept_terms, :boolean, default: false, null: false
    add_column :internship_agreements, :teacher_accept_terms, :boolean, default: false, null: false
  end
end
