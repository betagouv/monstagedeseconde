class AddMotherIdToInternhipOffer < ActiveRecord::Migration[7.1]
  def up
    remove_column :internship_offers, :mother_id, :integer, if_exists: true
    add_reference :internship_offers, :mother, foreign_key: { to_table: :internship_offers }, null: true,
                                               if_not_exists: true
  end

  def down
    remove_reference :internship_offers, :mother, if_exists: true
  end
end
