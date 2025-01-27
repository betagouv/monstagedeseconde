class RemoveHubspotIdFromUser < ActiveRecord::Migration[7.1]
  def up
    remove_column :users, :hubspot_id, :string
  end

  def down 
    add_column :users, :hubspot_id, :string, limit: 15, null: true
  end
end
