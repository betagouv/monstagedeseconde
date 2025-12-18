class AddSignedAtColumnToCorporationInternshipAgreement < ActiveRecord::Migration[7.1]
  def change
    add_column :corporation_internship_agreements, :signed_at, :datetime
  end
end
