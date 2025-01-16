class CreateInternshipApplicationStateChanges < ActiveRecord::Migration[7.1]
  def change
    create_table :internship_application_state_changes do |t|
      t.references :internship_application, null: false, foreign_key: true
      t.references :author, polymorphic: true
      t.string :from_state
      t.string :to_state, null: false
      t.jsonb :metadata, default: {}
      t.timestamps
    end

    add_index :internship_application_state_changes, %i[internship_application_id created_at]
  end
end
