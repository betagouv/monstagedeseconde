class CreateMultiInternshipAgreements < ActiveRecord::Migration[7.1]
  def change
    create_table :multi_internship_agreements do |t|
      t.uuid :uuid, null: false, default: -> { "gen_random_uuid()" }
      t.references :internship_application, null: false, foreign_key: true
      t.string :weekly_hours, limit: 200
      t.jsonb :daily_hours
      t.string :siret, limit: 14, null: true
      t.string :organisation_representative_role, limit: 150, null: false
      t.string :student_address, limit: 170, null: false
      t.string :student_phone, limit: 20
      t.string :school_representative_phone, limit: 20, null: false
      t.string :student_legal_representative_email, limit: 100, null: false
      t.string :student_refering_teacher_email, limit: 100, null: true
      t.string :student_legal_representative_full_name, limit: 100, null: false
      t.string :student_refering_teacher_full_name, limit: 100, null: true
      t.string :student_legal_representative_phone, limit: 20, null: false
      t.string :student_legal_representative_2_full_name, limit: 100, null: true
      t.string :student_legal_representative_2_email, limit: 100, null: true
      t.string :student_legal_representative_2_phone, limit: 20, null: true
      t.string :school_representative_email, limit: 100, null: false
      t.datetime :discarded_at, null: true, default: nil
      t.text :lunch_break, limit: 1500
      t.string :legal_status, limit: 50
      t.date :student_birth_date, null: false
      t.boolean :pai_project, default: false
      t.boolean :pai_trousse_family, default: false
      t.string :access_token, limit: 16, null: false
      t.string :student_full_name, limit: 100, null: false
      t.string :activity_scope, limit: 1500, null: false
      t.references :coordinator, foreign_key: { to_table: :users }, null: false

      t.timestamps
    end
  end
end
