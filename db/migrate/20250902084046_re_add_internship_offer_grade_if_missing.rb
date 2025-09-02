class ReAddInternshipOfferGradeIfMissing < ActiveRecord::Migration[7.1]
  def up
    unless Rails.env.production? || table_exists?(:internship_offer_grades)
      create_table :internship_offer_grades do |t|
        t.references :internship_offer, null: false, foreign_key: true
        t.references :grade, null: false, foreign_key: true
        t.timestamps
      end
    end
  end 
  def down
    # drop_table :internship_offer_grades if table_exists?(:internship_offer_grades) && !Rails.env.production?
  end
end
