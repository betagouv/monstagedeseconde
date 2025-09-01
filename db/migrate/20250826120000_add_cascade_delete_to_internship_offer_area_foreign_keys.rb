class AddCascadeDeleteToInternshipOfferAreaForeignKeys < ActiveRecord::Migration[7.0]
  def up
    # Drop existing foreign key constraints
    remove_foreign_key :area_notifications, :internship_offer_areas, name: 'fk_rails_2194cad748'
    remove_foreign_key :internship_offers, :internship_offer_areas, name: 'fk_rails_9bcd71f8ef'

    # Re-add foreign key constraints with CASCADE DELETE
    add_foreign_key :area_notifications, :internship_offer_areas,
                    column: :internship_offer_area_id,
                    name: 'fk_rails_2194cad748',
                    on_delete: :cascade

    add_foreign_key :internship_offers, :internship_offer_areas,
                    column: :internship_offer_area_id,
                    name: 'fk_rails_9bcd71f8ef',
                    on_delete: :cascade

    drop_table :internship_offer_grades, if_exists: true
    create_table :internship_offer_grades do |t|
        t.bigint :grade_id, null: false
        t.bigint :internship_offer_id, null: falsefk_rails_e13d61cd66
        t.timestamps
    end

    add_index :internship_offer_grades, :grade_id
    add_index :internship_offer_grades, :internship_offer_id

    add_foreign_key :internship_offer_grades, :grades, column: :grade_id
    add_foreign_key :internship_offer_grades, :internship_offers, column: :internship_offer_id
  end

  def down
    drop_table :internship_offer_grades, if_exists: true
    # Drop CASCADE DELETE foreign key constraints
    remove_foreign_key :area_notifications, :internship_offer_areas, name: 'fk_rails_2194cad748'
    remove_foreign_key :internship_offers, :internship_offer_areas, name: 'fk_rails_9bcd71f8ef'

    # Re-add original foreign key constraints (without CASCADE)
    add_foreign_key :area_notifications, :internship_offer_areas,
                    column: :internship_offer_area_id,
                    name: 'fk_rails_2194cad748'

    add_foreign_key :internship_offers, :internship_offer_areas,
                    column: :internship_offer_area_id,
                    name: 'fk_rails_9bcd71f8ef'
  end
end
