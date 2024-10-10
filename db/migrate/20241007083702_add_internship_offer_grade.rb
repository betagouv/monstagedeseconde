class AddInternshipOfferGrade < ActiveRecord::Migration[7.1]
  def change
    create_table :grades do |t|
      t.string :name, null: false, limit: 40
      t.string :short_name, null: false, limit: 30
      t.string :school_year_end_month, null: false, limit: 2
      t.string :school_year_end_day, null: false, limit: 2
      t.timestamps
    end

    create_table :internship_offer_grades do |t|
      t.references :internship_offer, null: false, foreign_key: true
      t.references :grade, null: false, foreign_key: true

      t.timestamps
    end
  end
end
