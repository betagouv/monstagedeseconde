# frozen_string_literal: true

class RemoveInternshipOfferInfosTables < ActiveRecord::Migration[7.2]
  def up
    drop_table :internship_offer_info_weeks, if_exists: true
    drop_table :internship_offer_infos, if_exists: true
  end

  def down
    # Tables obsolètes, pas de rollback nécessaire
  end
end
