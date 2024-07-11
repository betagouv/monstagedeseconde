class CreateFielsForFormerRichTextFields < ActiveRecord::Migration[7.1]
  def up
    add_column :internship_applications, :motivation_tmp, :text
    add_column :internship_applications, :rejected_message_tmp, :text
    add_column :internship_applications, :canceled_by_employer_message_tmp, :text

    add_column :internship_offer_infos, :description_str, :string, limit: 500
    add_column :internship_offers, :description_str, :string, limit: 500

    add_column :internship_agreements, :activity_scope_tmp, :text
    add_column :internship_agreements, :activity_preparation_tmp, :text
    add_column :internship_agreements, :activity_learnings_tmp, :text
    add_column :internship_agreements, :activity_rating_tmp, :text
    add_column :internship_agreements, :skills_observe_tmp, :text
    add_column :internship_agreements, :skills_communicate_tmp, :text
    add_column :internship_agreements, :skills_understand_tmp, :text
    add_column :internship_agreements, :skills_motivation_tmp, :text

    add_column :schools, :agreement_conditions_tmp, :text
  end

  def down
    remove_column :internship_applications, :motivation_tmp, :text
    remove_column :internship_applications, :rejected_message_tmp, :text
    remove_column :internship_applications, :canceled_by_employer_message_tmp, :text

    remove_column :internship_offer_infos, :description_str, :string
    remove_column :internship_offers, :description_str, :string

    remove_column :internship_agreements, :activity_scope_tmp, :text
    remove_column :internship_agreements, :activity_preparation_tmp, :text
    remove_column :internship_agreements, :activity_learnings_tmp, :text
    remove_column :internship_agreements, :activity_rating_tmp, :text
    remove_column :internship_agreements, :skills_observe_tmp, :text
    remove_column :internship_agreements, :skills_communicate_tmp, :text
    remove_column :internship_agreements, :skills_understand_tmp, :text
    remove_column :internship_agreements, :skills_motivation_tmp, :text

    remove_column :schools, :agreement_conditions_tmp, :text
  end
end
