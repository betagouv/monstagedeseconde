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

    test 'cpe rattaché à deux écoles voit les boutons de navigation entre établissements sur la page des classes' do
      school_1 = create(:school)
      school_2 = create(:school)
      cpe = create(:cpe, school: school_1)
      UserSchool.create!(user: cpe, school: school_2)

      sign_in(cpe)
      visit dashboard_school_class_rooms_path(school_1)

      assert_selector "button[name='school_id'][value='#{school_2.id}']",
                      text: "Voir les classes du #{school_2.name}"
      refute_selector "button[name='school_id'][value='#{school_1.id}']"
    end
  end
end
