class AddColumnToMultiCorporation < ActiveRecord::Migration[7.1]
  def change
    add_column :multi_corporations, :signatures_launched_at, :datetime
  end
end
