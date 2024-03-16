class AddHubspotIdToUsers < ActiveRecord::Migration[7.1]
  def change
    add_column :users, :hubspot_id, :string
  end
end
