module ReviewRebuild
  module SchoolManagementUpdateSteps
    extend ActiveSupport::Concern

    def create_school_management_updates
      Users::SchoolManagement.find_each do |school_management|
        next unless school_management.school

        UserSchool.find_or_create_by!(user: school_management, school: school_management.school)
      end
    end
  end
end
