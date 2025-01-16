class UpdateDescriptionLimitInInternshipOffer < ActiveRecord::Migration[7.1]
  def up
    change_column :internship_offers, :description, :string, limit: 1500
    change_column :internship_offers, :employer_description, :string, limit: 1500
    change_column :internship_occupations, :description, :string, limit: 1500
  end

  def down
    change_column :internship_offers, :description, :string, limit: 500
    change_column :internship_offers, :employer_description, :string, limit: 250
    change_column :internship_occupations, :description, :string, limit: 500
  end
end
