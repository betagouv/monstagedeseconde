class ConvertMailActionItemUserToPolymorphicRecipient < ActiveRecord::Migration[8.1]
  def change
    # Add polymorphic columns
    add_column :mail_action_items, :recipient_type, :string
    add_column :mail_action_items, :recipient_id, :bigint

    # Migrate existing data: all current users become User recipient type
    reversible do |dir|
      dir.up do
        execute "UPDATE mail_action_items SET recipient_type = 'User', recipient_id = user_id WHERE user_id IS NOT NULL"
      end
      dir.down do
        execute "UPDATE mail_action_items SET user_id = recipient_id WHERE recipient_type = 'User'"
      end
    end

    # Add not null constraint after data migration
    change_column_null :mail_action_items, :recipient_type, false
    change_column_null :mail_action_items, :recipient_id, false

    # Add polymorphic index
    add_index :mail_action_items, [ :recipient_type, :recipient_id ]

    # Replace old index with new one
    remove_index :mail_action_items, name: "index_mail_action_items_on_user_and_action_urgency_resolved"
    add_index :mail_action_items, [ :recipient_type, :recipient_id, :action_type, :urgency_level, :resolved_at ],
              name: "index_mail_action_items_on_recipient_pl_action_urgency_resolved"

    # Remove old user_id column
    remove_column :mail_action_items, :user_id
  end
end
