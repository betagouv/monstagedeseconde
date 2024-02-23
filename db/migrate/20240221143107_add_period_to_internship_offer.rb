class AddPeriodToInternshipOffer < ActiveRecord::Migration[7.1]
  def change
    # period enum : { full_time: 0, week_1: 1, week_2: 2 }
    add_column :internship_offers, :period, :integer, default: 0, null: false
    add_column :hosting_infos, :period, :integer, default: 0, null: false 

    add_index :internship_offers, :period
    add_index :hosting_infos, :period
  end
end
