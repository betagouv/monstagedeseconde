class AddMailActionItem < ActiveRecord::Migration[8.1]
  def change
    create_table :mail_action_items do |t|
      t.string :action_name
      t.references :user, null: false, foreign_key: true
      t.datetime :first_seen_at
      t.datetime :stale_at
      t.datetime :last_notified_at
      t.datetime :resolved_at
      t.integer :deliveries_count, default: 0
      t.integer :max_deliveries_count, default: 1
      t.jsonb :payload

      t.timestamps
    end
    add_column :mail_action_items, :action_type, :action_type
    add_column :mail_action_items, :urgency_level, :urgency_level
    add_index :mail_action_items, %i[ user_id action_type urgency_level resolved_at ],
              name: "index_mail_action_items_on_user_and_action_urgency_resolved"
  end
end
