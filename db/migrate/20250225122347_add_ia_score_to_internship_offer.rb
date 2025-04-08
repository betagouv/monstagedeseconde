class AddIaScoreToInternshipOffer < ActiveRecord::Migration[7.1]
  def change
    add_column :internship_offers, :ia_score, :integer
    add_column :internship_occupations, :ia_score, :integer
  end
end
