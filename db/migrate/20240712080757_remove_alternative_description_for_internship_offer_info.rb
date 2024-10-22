class RemoveAlternativeDescriptionForInternshipOfferInfo < ActiveRecord::Migration[7.1]
  def up
    remove_column :internship_offer_infos, :description_str
    remove_column :internship_offer_infos, :description_tmp

    remove_column :internship_offers, :description_str
  end

  def down
    add_column :internship_offer_infos, :description_str, :text
    add_column :internship_offer_infos, :description_tmp, :text

    add_column :internship_offers, :description_str, :text
  end
end
