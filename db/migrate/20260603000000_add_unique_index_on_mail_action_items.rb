class AddUniqueIndexOnMailActionItems < ActiveRecord::Migration[7.2]
  def change
    add_index :mail_action_items,
              %i[action_name recipient_type recipient_id internship_agreement_id internship_application_id],
              unique: true,
              name: "index_mail_action_items_uniqueness"
  end
end
