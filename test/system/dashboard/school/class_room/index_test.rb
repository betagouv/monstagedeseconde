require 'application_system_test_case'
module Dashboard
  class SchoolClassRoomIndexTest < ApplicationSystemTestCase
    include Devise::Test::IntegrationHelpers

    test 'modal raises once only' do
      school = create(:school, :with_school_manager)
      class_room = create(:class_room, school: school)

      sign_in(school.school_manager)
      visit dashboard_school_class_rooms_path(school)
    end
  end
end
