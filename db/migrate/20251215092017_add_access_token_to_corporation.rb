class AddAccessTokenToCorporation < ActiveRecord::Migration[7.1]
  def change
    add_column :corporations, :uuid, :string, default: 'gen_random_uuid()', null: false
    add_index :corporations, :uuid, unique: true
  end
end
