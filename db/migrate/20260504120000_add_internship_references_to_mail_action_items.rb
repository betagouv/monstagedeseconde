class AddInternshipReferencesToMailActionItems < ActiveRecord::Migration[8.1]
  def change
    add_reference :mail_action_items, :internship_offer, foreign_key: true, null: true
    add_reference :mail_action_items, :internship_application, foreign_key: true, null: true
    add_reference :mail_action_items, :internship_agreement, foreign_key: true, null: true
  end
end
