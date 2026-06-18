# frozen_string_literal: true

class CreateMailActionConfigs < ActiveRecord::Migration[7.1]
  def change
    create_table :mail_action_configs do |t|
      t.string :action_name, null: false
      t.string :urgency_level, null: false
      t.integer :max_deliveries_count, null: false
      t.timestamps
    end
    add_index :mail_action_configs, :action_name, unique: true
  end
end
