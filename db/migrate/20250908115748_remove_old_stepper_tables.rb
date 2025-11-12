class RemoveOldStepperTables < ActiveRecord::Migration[7.1]
  def up
    remove_column :internship_offers, :organisation_id
    remove_column :internship_offers, :internship_offer_info_id
    remove_column :internship_offers, :hosting_info_id
    remove_column :internship_offers, :practical_info_id
    remove_column :internship_offers, :tutor_id

    drop_table :hosting_info_weeks, if_exists: true

    drop_table :tutors, if_exists: true
    drop_table :practical_infos, if_exists: true
    drop_table :organisations, if_exists: true
    drop_table :hosting_infos, if_exists: true
  end

  def down
    #
  end
end
