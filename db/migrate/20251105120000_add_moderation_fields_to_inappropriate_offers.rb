# frozen_string_literal: true

class AddModerationFieldsToInappropriateOffers < ActiveRecord::Migration[7.1]
  def up
    add_column :inappropriate_offers, :moderation_action, :string
    add_column :inappropriate_offers, :message_to_offerer, :text
    add_column :inappropriate_offers, :decision_date, :datetime
    add_column :inappropriate_offers, :internal_comment, :text
    add_reference :inappropriate_offers, :moderator, foreign_key: { to_table: :users }, index: true
  end

  def down
    remove_column :inappropriate_offers, :moderation_action
    remove_column :inappropriate_offers, :message_to_offerer
    remove_column :inappropriate_offers, :decision_date
    remove_column :inappropriate_offers, :internal_comment
    remove_reference :inappropriate_offers, :moderator, foreign_key: { to_table: :users }, index: true
  end
end

