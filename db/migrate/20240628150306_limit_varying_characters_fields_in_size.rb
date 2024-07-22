class LimitVaryingCharactersFieldsInSize < ActiveRecord::Migration[7.1]
  def up
    change_column :organisations, :siren, :string, limit: 9
    change_column :organisations, :siret, :string, limit: 14
    change_column :organisations, :employer_website, :string, limit: 560
    
    change_column :internship_offers, :type, :string, limit: 40
    change_column :internship_offers, :siret, :string, limit: 14
    change_column :internship_offers, :academy, :string, limit: 50

    change_column :internship_applications, :internship_offer_type, :string, limit: 50
    change_column :internship_applications, :student_legal_representative_full_name, :string, limit: 150
    change_column :internship_applications, :student_legal_representative_email, :string, limit: 109
    change_column :internship_applications, :student_legal_representative_phone, :string, limit: 50
    
    change_column :internship_agreements, :student_address, :string, limit: 170
    change_column :internship_agreements, :date_range, :string, limit: 210
    change_column :internship_agreements, :organisation_representative_email, :string, limit: 70
    change_column :internship_agreements, :legal_status, :string, limit: 20
    change_column :internship_agreements, :internship_address, :string, limit: 500
    change_column :internship_agreements, :employer_name, :string, limit: 180
    change_column :internship_agreements, :employer_contact_email, :string, limit: 71
  end

  def down
  end
end
