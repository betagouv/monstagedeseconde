class CreateWaitingListEntries < ActiveRecord::Migration[7.1]
  def change
    create_table :waiting_list_entries do |t|
      t.string :email

      t.timestamps
    end
  end
end
