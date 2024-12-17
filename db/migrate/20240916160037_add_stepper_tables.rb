class AddStepperTables < ActiveRecord::Migration[7.1]
  def change
    create_table :internship_occupations do |t|
      t.string :title, null: false, limit: 150
      t.text :description, limit: 250
      t.string :street, null: false, limit: 200
      t.string :zipcode, null: false, limit: 5
      t.string :city, null: false, limit: 50
      t.string :department, null: false, default: '', limit: 40
      t.st_point :coordinates, geographic: true
      t.index :coordinates, using: :gist

      t.belongs_to :employer, foreign_key: {to_table: :users}

      t.timestamps
    end

    create_table :entreprises do |t|
      t.boolean :manual_enter, null: false, default: false
      t.string :siret, null: false, limit: 14
      t.boolean :is_public, null: false, default: false
      t.string :employer_name, null: false, limit: 150
      t.string :chosen_employer_name, null: true, limit: 150
      t.string :entreprise_city, null: false, limit: 50
      t.string :entreprise_zipcode, null: false, limit: 5
      t.string :entreprise_street, null: false, limit: 200
      t.st_point :entreprise_coordinates, geographic: true
      t.index :entreprise_coordinates, using: :gist
      t.string :tutor_first_name, null: false, limit: 50
      t.string :tutor_last_name, null: false, limit: 50
      t.string :tutor_email, null: false, limit: 100
      t.string :tutor_phone, null: false, limit: 20
      t.string :tutor_function, null: false, limit: 120

      t.belongs_to :group, foreign_key: true
      t.belongs_to :internship_application, foreign_key: true

      t.timestamps
    end

    # execute <<-SQL
    #   CREATE TYPE school_track_enum AS ENUM ('troisieme', 'seconde');
    # SQL

    create_table :plannings do |t|
      t.integer :weeks_count, null: false
      t.integer :max_candidates, default: 1, default: 1, null: false
      t.integer :max_students_per_group, default: 1, null: false
      t.integer :remaining_seats_count, default: 0

      t.string :weekly_lunch_break, null: false, limit: 200
      t.string :weekly_hours, array: true, default: [], limit: 400

      t.jsonb :daily_hours, default: {}
      t.jsonb :daily_lunch_break, default: {}

      t.belongs_to :entreprise, foreign_key: true
      t.belongs_to :internship_applications, foreign_key: true
      t.belongs_to :school, foreign_key: true, null: true

      t.timestamps
    end
  end
end
