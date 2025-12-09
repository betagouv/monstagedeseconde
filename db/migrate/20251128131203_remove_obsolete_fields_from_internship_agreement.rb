class RemoveObsoleteFieldsFromInternshipAgreement < ActiveRecord::Migration[7.1]
  def up
    remove_column :internship_agreements, :activity_rating
    remove_column :internship_agreements, :activity_learnings
    remove_column :internship_agreements, :activity_preparation

    remove_column :internship_agreements, :organisation_representative_email

    remove_column :internship_agreements,:skills_communicate
    remove_column :internship_agreements,:skills_understand
    remove_column :internship_agreements,:skills_motivation
    remove_column :internship_agreements,:skills_observe
  end

  def down
    add_column :internship_agreements, :activity_rating, :text
    add_column :internship_agreements, :activity_learnings, :text
    add_column :internship_agreements, :activity_preparation, :text
    
    add_column :internship_agreements, :organisation_representative_email, :string

    add_column :skills_communicate, :boolean, default: false, null: false
    add_column :skills_understand, :boolean, default: false, null: false
    add_column :skills_motivation, :boolean, default: false, null: false
    add_column :skills_observe, :boolean, default: false, null: false
  end
end
