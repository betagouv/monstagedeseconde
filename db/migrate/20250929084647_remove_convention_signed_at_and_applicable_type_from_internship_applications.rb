class RemoveConventionSignedAtAndApplicableTypeFromInternshipApplications < ActiveRecord::Migration[7.1]
  def change
    remove_column :internship_applications, :convention_signed_at
    remove_column :internship_applications, :applicable_type
    remove_column :internship_applications, :week_id
  end
end
