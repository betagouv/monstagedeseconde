# frozen_string_literal: true

class CreateMultiCoordinators < ActiveRecord::Migration[7.1]
  def change
    create_table :multi_coordinators do |t|
      t.string :siret, limit: 14
      t.integer :sector_id
      t.string :employer_name, limit: 120
      t.string :employer_chosen_name, null: false, limit: 120
      t.string :employer_address, limit: 250
      t.string :employer_chosen_address, null: false, limit: 250
      t.string :city, null: false, limit: 60
      t.string :zipcode, null: false, limit: 6
      t.string :street, null: false, limit: 300
      t.string :phone, null: false, limit: 20

      t.belongs_to :multi_activity, foreign_key: true, null: false

      t.timestamps
    end

    add_index :multi_coordinators, :sector_id
  end
end
