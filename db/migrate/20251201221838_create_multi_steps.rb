class CreateMultiSteps < ActiveRecord::Migration[7.1]
  def change
    
    # drop_table :multi_multi_corporations, if_exists: true, force: :cascade
    # drop_table :multi_corporations, if_exists: true, force: :cascade
    # drop_table :corporations, if_exists: true, force: :cascade

    create_table :multi_corporations do |t|
      t.references :multi_coordinator, null: false, foreign_key: true
      t.timestamps
    end

    create_table :corporations do |t|
      t.references :multi_corporation, null: false, foreign_key: true
      
      t.string :siret, limit: 14
      t.references :sector, foreign_key: true
      
      t.string :employer_name, limit: 120
      t.string :employer_address, limit: 250
      t.string :phone, limit: 20
      
      t.string :city, limit: 60
      t.string :zipcode, limit: 6
      t.string :street, limit: 300
      
      t.string :internship_city, limit: 60
      t.string :internship_zipcode, limit: 6
      t.string :internship_street, limit: 300
      t.string :internship_phone, limit: 20
      
      t.string :tutor_name, limit: 150
      t.string :tutor_role_in_company, limit: 250
      t.string :tutor_email, limit: 120
      t.string :tutor_phone, limit: 20

      t.timestamps
    end
  end
end
