require 'application_system_test_case'

module Dashboard
  class SchoolClassRoomEditTest < ApplicationSystemTestCase
    include Devise::Test::IntegrationHelpers

    test 'school manager or teacher can invite students to monstagedeseconde' do
      school = create(:school, :with_school_manager)
      class_room = create(:class_room, school: school)
      teacher = create(:teacher, school: school, class_room: class_room)
      create(:student, school: school, class_room: class_room)

      sign_in(teacher)
      visit dashboard_school_class_room_students_path(school, class_room)
      click_link('Ajouter des élèves à cette classe')
      fill_in "Prénom de l'élève", with: 'Martin'
      fill_in "Nom de l'élève", with: 'Dupont'
      fill_in "Adresse électronique", with: 'martin.dupont@free.fr'
      find("#user_birth_date").set("01/01/2008")
      find("label[for='select-gender-boy']").click
      click_button("Confirmer l'inscription de l'élève")
      find('.alert-success', text: 'Elève créé !')
    end
  end
end