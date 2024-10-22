class AddMissingTextFieldToReplaceRichTextOnes < ActiveRecord::Migration[7.1]
  def up
    add_column :internship_applications, :canceled_by_student_message_tmp, :text
    add_column :internship_applications, :approved_message_tmp, :text

    add_column :internship_offer_infos, :description_tmp, :text

    add_column :users, :resume_educational_background_tmp, :text
    add_column :users, :resume_other_tmp, :text
    add_column :users, :resume_languages_tmp, :text
  end

  def down
    remove_column :internship_applications, :canceled_by_student_message_tmp
    remove_column :internship_applications, :approved_message_tmp

    remove_column :internship_offer_infos, :description_tmp

    remove_column :users, :resume_educational_background_tmp
    remove_column :users, :resume_other_tmp
    remove_column :users, :resume_languages_tmp
  end
end
