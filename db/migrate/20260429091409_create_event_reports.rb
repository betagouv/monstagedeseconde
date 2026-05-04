class CreateEventReports < ActiveRecord::Migration[8.1]
  def change
    create_table :event_reports do |t|
      t.string :event_name
      t.string :stage
      t.integer :severity
      t.string :student_ine
      t.jsonb :json_payload
      t.string :code_line
      t.string :tag

      t.timestamps
    end
  end
end
