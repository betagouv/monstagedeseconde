class AddModalInfoToUser < ActiveRecord::Migration[7.1]
  def change
    add_column :users, :show_modal_info, :boolean, default: true, null: false
  end
end
