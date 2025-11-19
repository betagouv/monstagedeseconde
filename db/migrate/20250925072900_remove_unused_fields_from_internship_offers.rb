class RemoveUnusedFieldsFromInternshipOffers < ActiveRecord::Migration[7.1]
  def change
    remove_column :internship_offers, :tutor_name, :string
    remove_column :internship_offers, :tutor_phone, :string
    remove_column :internship_offers, :tutor_email, :string
    remove_column :internship_offers, :remaining_seats_count, :integer
    remove_column :internship_offers, :blocked_weeks_count, :integer
    remove_column :internship_offers, :total_applications_count, :integer
    remove_column :internship_offers, :approved_applications_count, :integer
    remove_column :internship_offers, :submitted_applications_count, :integer
    remove_column :internship_offers, :rejected_applications_count, :integer
    remove_column :internship_offers, :view_count, :integer
    remove_column :internship_offers, :total_male_applications_count, :integer
    remove_column :internship_offers, :total_female_applications_count, :integer
    remove_column :internship_offers, :total_male_approved_applications_count, :integer
    remove_column :internship_offers, :total_female_approved_applications_count, :integer
    remove_column :internship_offers, :max_students_per_group, :integer
    remove_column :internship_offers, :tutor_role, :string
    remove_column :internship_offers, :hidden_duplicate, :boolean
    remove_column :internship_offers, :ia_score, :integer
  end
end
