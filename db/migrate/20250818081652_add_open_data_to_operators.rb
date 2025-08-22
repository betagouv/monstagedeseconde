class AddOpenDataToOperators < ActiveRecord::Migration[7.1]
  def change
    add_column :operators, :open_data, :boolean, default: true
    add_column :internship_offers, :open_data, :boolean, default: true
  end
end
