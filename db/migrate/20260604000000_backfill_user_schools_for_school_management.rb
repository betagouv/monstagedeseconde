class BackfillUserSchoolsForSchoolManagement < ActiveRecord::Migration[7.1]
  def up
    Users::SchoolManagement.where.not(school_id: nil).find_each do |user|
      UserSchool.find_or_create_by!(user_id: user.id, school_id: user.school_id)
    end
  end

  def down
    # intentionally left empty — removing backfilled rows is unsafe
  end
end
