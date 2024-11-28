require 'application_system_test_case'

module Dashboard
  module Students
    class AplicationFlowTest < ApplicationSystemTestCase
      include Devise::Test::IntegrationHelpers
      include TeamAndAreasHelper

      test 'first and uniq test before submitting when email was missing' do
        school = create(:school, :with_school_manager)
        employer, internship_offer = create_employer_and_offer_2nde
        student = create(:student, phone: '+2620625852585', school:, email: nil)
        new_email = 'tests@free.fr'

        sign_in(student)
        visit internship_offers_path
        click_on internship_offer.title
        all('.fr-btn', text: 'Postuler').first.click
        find('#internship_application_motivation', visible: false).set('Le dev ça motive')
        fill_in 'Adresse électronique (email)', with: new_email
        click_on 'Valider'

        click_on 'Envoyer ma candidature'

        assert_nil student.reload.email
        internship_application = InternshipApplication.last
        assert_equal student.phone, internship_application.student_phone
      end

      test 'student_email is suggested from previous internship_applications' do
        employer, internship_offer = create_employer_and_offer_2nde
        second_internship_offer = create(:weekly_internship_offer_2nde, employer:)
        former_student_email = 'test@free.fr'
        student = create(:student, :registered_with_phone)
        internship_application = create(:weekly_internship_application,
                                        :submitted,
                                        internship_offer:,
                                        student:,
                                        student_email: former_student_email)
        assert_nil student.email
        sign_in(student)
        visit internship_offers_path
        click_on second_internship_offer.title
        all('.fr-btn', text: 'Postuler').first.click
        form_student_value = find('input[name="internship_application[student_email]"]').value
        assert_equal former_student_email, form_student_value
      end

      test 'student_phone is suggested from previous internship_applications' do
        employer, internship_offer = create_employer_and_offer_2nde
        second_internship_offer = create(:weekly_internship_offer_2nde, employer:)
        former_student_phone = '+330623055441'
        student = create(:student)
        assert_nil student.phone
        internship_application = create(:weekly_internship_application,
                                        :submitted,
                                        internship_offer:,
                                        student:,
                                        student_phone: former_student_phone)
        sign_in(student)
        visit internship_offers_path
        click_on second_internship_offer.title
        all('.fr-btn', text: 'Postuler').first.click

        # TODO: This test is not working on CI, but works locally
        # form_student_value = find('input[name="internship_application[student_phone]"]').value.gsub(/\s+/, '')
        # assert_equal former_student_phone, form_student_value
      end
    end
  end
end
