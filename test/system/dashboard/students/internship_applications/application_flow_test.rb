require 'application_system_test_case'

module Dashboard
  module Students
    class AplicationFlowTest < ApplicationSystemTestCase
      include Devise::Test::IntegrationHelpers
      include TeamAndAreasHelper

      test 'first and uniq test before submitting when phone number was missing' do
        school = create(:school, :with_school_manager )
        employer, internship_offer = create_employer_and_offer
        student = create(:student, school: school)
        new_phone_number = '0606060606'
        sign_in(student)
        visit internship_offers_path
        click_on internship_offer.title
        all('.fr-btn', text: 'Postuler').first.click
        find('#internship_application_motivation', visible: false).set("Le dev ça motive")
        within(".react-tel-input") do
          find('input[name="internship_application[student_phone]"]').set(new_phone_number)
        end
        click_on 'Valider'

        find('.fr-h3', text: 'Rappel du stage')
        formatted_phone = "+33#{new_phone_number}"
        assert_equal formatted_phone,  student.reload.phone
        internship_application = InternshipApplication.last
        assert_equal "Le dev ça motive", internship_application.motivation.to_plain_text
        assert_equal formatted_phone, internship_application.student_phone
        assert_equal student.email, internship_application.student_email
      end

      test 'first and uniq test before submitting when email was missing' do
        school = create(:school, :with_school_manager )
        employer, internship_offer = create_employer_and_offer
        student = create(:student, phone: '+2620625852585', school: school, email: nil)
        new_email = 'tests@free.fr'

        sign_in(student)
        visit internship_offers_path
        click_on internship_offer.title
        all('.fr-btn', text: 'Postuler').first.click
        find('#internship_application_motivation', visible: false).set("Le dev ça motive")
        fill_in 'Adresse électronique (email)', with: new_email
        click_on 'Valider'

        find('.fr-h3', text: 'Rappel du stage')
        assert_equal new_email,  student.reload.email
        internship_application = InternshipApplication.last
        assert_equal student.phone, internship_application.student_phone
        assert_equal student.email, internship_application.student_email
      end
    end
  end
end
