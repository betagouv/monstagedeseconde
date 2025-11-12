class CreateInappropriateOffers < ActiveRecord::Migration[7.1]
  def up
    execute <<-SQL
      CREATE TYPE inappropriate_ground AS ENUM('suspicious_content', 'inappropriate_content', 'incorrect_address', 'false_or_misleading_information', 'other' );
    SQL
    create_table :inappropriate_offers do |t|
      t.references :internship_offer, null: false
      t.references :user, null: true
      t.text :details, limit: 350

      t.timestamps
    end
    add_column :inappropriate_offers, :ground, :inappropriate_ground, null: false

    add_index :inappropriate_offers, :internship_offer_id unless index_exists?(:inappropriate_offers, :internship_offer_id)
    # kind of reset
    remove_index :inappropriate_offers, :ground if index_exists?(:inappropriate_offers, :ground)
    add_index :inappropriate_offers, :ground
  end

  def down
    remove_index :inappropriate_offers, :ground if index_exists?(:inappropriate_offers, :ground)
    remove_index :inappropriate_offers, :internship_offer_id if index_exists?(:inappropriate_offers, :internship_offer_id)
    drop_table :inappropriate_offers
    execute <<-SQL
      DROP TYPE inappropriate_ground;
    SQL
  end
end
