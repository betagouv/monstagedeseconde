class UpdateTmpFieldNamesToTheirOriginalNames < ActiveRecord::Migration[7.1]
  def up
    rename_column :internship_applications, :motivation_tmp, :motivation
    rename_column :internship_applications, :rejected_message_tmp, :rejected_message
    rename_column :internship_applications, :canceled_by_employer_message_tmp, :canceled_by_employer_message

    rename_column :internship_agreements, :activity_scope_tmp, :activity_scope
    rename_column :internship_agreements, :activity_preparation_tmp, :activity_preparation
    rename_column :internship_agreements, :activity_learnings_tmp, :activity_learnings
    rename_column :internship_agreements, :activity_rating_tmp, :activity_rating
    rename_column :internship_agreements, :skills_observe_tmp, :skills_observe
    rename_column :internship_agreements, :skills_communicate_tmp, :skills_communicate
    rename_column :internship_agreements, :skills_understand_tmp, :skills_understand
    rename_column :internship_agreements, :skills_motivation_tmp, :skills_motivation

    rename_column :schools, :agreement_conditions_tmp, :agreement_conditions

    rename_column :internship_applications, :canceled_by_student_message_tmp, :canceled_by_student_message
    rename_column :internship_applications, :approved_message_tmp, :approved_message

    rename_column :users, :resume_educational_background_tmp, :resume_educational_background
    rename_column :users, :resume_other_tmp, :resume_other
    rename_column :users, :resume_languages_tmp, :resume_languages
  end

  def down
    rename_column :internship_applications, :motivation, :motivation_tmp
    rename_column :internship_applications, :rejected_message, :rejected_message_tmp
    rename_column :internship_applications, :canceled_by_employer_message, :canceled_by_employer_message_tmp

    rename_column :internship_agreements, :activity_scope, :activity_scope_tmp
    rename_column :internship_agreements, :activity_preparation, :activity_preparation_tmp
    rename_column :internship_agreements, :activity_learnings, :activity_learnings_tmp
    rename_column :internship_agreements, :activity_rating, :activity_rating_tmp
    rename_column :internship_agreements, :skills_observe, :skills_observe_tmp
    rename_column :internship_agreements, :skills_communicate, :skills_communicate_tmp
    rename_column :internship_agreements, :skills_understand, :skills_understand_tmp
    rename_column :internship_agreements, :skills_motivation, :skills_motivation_tmp

    rename_column :internship_applications, :canceled_by_student_message, :canceled_by_student_message_tmp
    rename_column :internship_applications, :approved_message, :approved_message_tmp

    rename_column :users, :resume_educational_background, :resume_educational_background_tmp
    rename_column :users, :resume_other, :resume_other_tmp
    rename_column :users, :resume_languages, :resume_languages_tmp
  end
end
