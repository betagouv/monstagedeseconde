# frozen_string_literal: true

class CreateMultiActivities < ActiveRecord::Migration[7.1]
  def change
    create_table :multi_activities do |t|
      t.string :title, null: false, limit: 120
      t.text :description, null: false, limit: 1500

      t.belongs_to :employer, foreign_key: { to_table: :users }, null: false

      t.timestamps
    end
  end
end

