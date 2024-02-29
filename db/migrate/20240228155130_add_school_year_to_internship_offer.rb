class AddSchoolYearToInternshipOffer < ActiveRecord::Migration[7.1]
  def up
    add_column :internship_offers, :school_year, :integer, null: false, default: 0
  end
  
  def down
    remove_column :internship_offers, :school_year
  end
end
