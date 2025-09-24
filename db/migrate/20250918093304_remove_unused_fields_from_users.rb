class RemoveUnusedFieldsFromUsers < ActiveRecord::Migration[7.1]
  def change
    remove_column :users, :banners, :jsonb
    remove_column :users, :subscribed_to_webinar_at, :datetime
    remove_column :users, :survey_answered, :boolean
    remove_column :users, :resume_educational_background, :text
  end
end
