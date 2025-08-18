class UpdateMainTeachersRolesIntoMereTeachers < ActiveRecord::Migration[7.1]
  def change
    Users::SchoolManagement.where(role: 'main_teacher').find_each do |user|
      user.update_columns(role: 'teacher')
    end
  end
end
