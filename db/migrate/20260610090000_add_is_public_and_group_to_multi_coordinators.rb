# frozen_string_literal: true

class AddIsPublicAndGroupToMultiCoordinators < ActiveRecord::Migration[7.2]
  def change
    add_column :multi_coordinators, :is_public, :boolean, null: false, default: false
    add_reference :multi_coordinators, :group, foreign_key: true, null: true
  end
end
