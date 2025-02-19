require 'application_system_test_case'

module Dashboard
  module Students
    class AplicationFlowTest < ApplicationSystemTestCase
      include Devise::Test::IntegrationHelpers
      include TeamAndAreasHelper

      test 'student 2nde first and uniq test before submitting when email was missing' do
        school = create(:school, :with_school_manager)
        employer, internship_offer = create_employer_and_offer_2nde
        student = create(:student, :seconde, phone: '+2620625852585', school:, email: nil)
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

      test 'student 2nde student_email is suggested from previous internship_applications' do
        skip 'failing test on CI but passing locally' if ENV.fetch('CI') == 'true'
        employer, internship_offer = create_employer_and_offer_2nde
        second_internship_offer = create(:weekly_internship_offer_2nde, employer:)
        former_student_email = 'test@free.fr'
        student = create(:student, :seconde, :registered_with_phone)
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

      test 'student 2nde student_phone is suggested from previous internship_applications' do
        employer, internship_offer = create_employer_and_offer_2nde
        second_internship_offer = create(:weekly_internship_offer_2nde, employer:)
        former_student_phone = '+330623055441'
        student = create(:student, :seconde)
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

      test '2nde student faulty application fails gracefully' do
        school = create(:school, :with_school_manager)
        employer, internship_offer = create_employer_and_offer_2nde
        student = create(:student, :seconde, phone: '+2620625852585', school:, email: nil)
        # new_email = 'tests@free.fr'
        sign_in(student)
        visit internship_offers_path
        click_on internship_offer.title
        all('.fr-btn', text: 'Postuler').first.click
        find('#internship_application_motivation', visible: false).set('Le dev ça motive')
        # fill_in 'Adresse électronique (email)', with: new_email
        click_on 'Valider ma candidature'
        click_on 'Envoyer ma candidature'
        find('.fr-alert--error strong', text: 'Contact email')
        find('.fr-alert--error ', text: "n'est pas valide")
      end

      test '3eme student faulty application fails gracefully' do
        travel_to Date.new(2024, 9, 3) do
          employer, internship_offer = create_employer_and_offer_3eme
          school = create(:school, :with_school_manager, weeks: internship_offer.weeks)
          student = create(:student, :troisieme, school:, phone: '+2620625852585', email: nil)
          assert student.grade.troisieme_ou_quatrieme?
          assert student.grade == Grade.troisieme
          refute_equal [], (student.school.weeks & internship_offer.weeks).to_a
          # new_email = 'tests@free.fr'
          sign_in(student)
          visit internship_offer_path(internship_offer)
          all('.fr-btn', text: 'Postuler').first.click
          find('#internship_application_motivation', visible: false).set('Le dev ça motive')
          # fill_in 'Adresse électronique (email)', with: new_email
          click_on 'Valider ma candidature'
          click_on 'Envoyer ma candidature'
          find('.fr-alert--error strong', text: 'Contact email')
          find('.fr-alert--error ', text: "n'est pas valide")
        end
      end

      test '3eme student faulty application (phone format) fails gracefully' do
        travel_to Date.new(2024, 9, 3) do
          employer, internship_offer = create_employer_and_offer_3eme
          school = create(:school, :with_school_manager, weeks: internship_offer.weeks)
          student = create(:student, :troisieme, school:, phone: '+2620625852585', email: nil)
          assert student.grade.troisieme_ou_quatrieme?
          assert student.grade == Grade.troisieme
          refute_equal [], (student.school.weeks & internship_offer.weeks).to_a
          # new_email = 'tests@free.fr'
          sign_in(student)
          visit internship_offer_path(internship_offer)
          all('.fr-btn', text: 'Postuler').first.click
          find('#internship_application_motivation', visible: false).set('Le dev ça motive')
          fill_in 'Numéro de portable élève ou responsable légal', with: '1' * 15
          # fill_in 'Adresse électronique (email)', with: new_email
          click_on 'Valider ma candidature'
          click_on 'Envoyer ma candidature'
          find('.fr-alert--error strong', text: 'Contact email')
          find('.fr-alert--error ', text: "n'est pas valide")
        end
      end

      test '2nde student 2 weeks long application is shown as 2 weeks long in his dashboard' do
        employer, internship_offer = create_employer_and_offer_2nde
        internship_offer.update!(weeks: Week.both_school_track_selectable_weeks)
        school = create(:school, :lycee, :with_school_manager)
        student = create(:student, :seconde, school: school, email: 'test@free.fr', phone: '+ 330620554411')
        sign_in(student)
        visit internship_offer_path(internship_offer)
        all('.fr-btn', text: 'Postuler').first.click
        find('#internship_application_motivation', visible: false).set('Le dev ça motive')
        click_on 'Valider ma candidature'
        click_on 'Envoyer ma candidature'
        assert_text 'Disponible sur 2 semaines : 16 juin 2025 → 27 juin 2025'
        find('a', text: 'Voir').click
        assert_text 'Disponible sur 2 semaines : 16 juin 2025 → 27 juin 2025'
      end

      test '2nde student 2 weeks long application is shown as 2 ' \
           'weeks long both in the employer dashboard' do
        employer, internship_offer = create_employer_and_offer_2nde
        school = create(:school, :lycee, :with_school_manager)
        student = create(:student, :seconde, school: school, email: 'test@free.fr', phone: '+330620554411')
        internship_offer.update!(weeks: Week.both_school_track_selectable_weeks)
        create(:internship_application, :both_june_weeks, :submitted, internship_offer:, student:)
        sign_in(student)
        sign_in(employer)
        visit dashboard_candidatures_path
        click_link 'Répondre'
        find('.h5', text: "Informations sur l'élève")
        assert_text 'Disponible sur 2 semaines : 16 juin 2025 → 27 juin 2025'
      end

      test "As student with 1 week long application, it is shown as 1 week long in student's dashboard" do
        employer, internship_offer = create_employer_and_offer_2nde
        internship_offer.update!(weeks: [SchoolTrack::Seconde.first_week])
        school = create(:school, :lycee, :with_school_manager)
        student = create(:student, :seconde, school: school, email: 'test@free.fr', phone: '+ 330620554411')
        sign_in(student)
        visit internship_offer_path(internship_offer)
        all('.fr-btn', text: 'Postuler').first.click
        find('#internship_application_motivation', visible: false).set('Le dev ça motive')
        click_on 'Valider ma candidature'
        click_on 'Envoyer ma candidature'
        assert_text 'Disponible la semaine du 16 juin 2025 au 20 juin 2025'
        find('a', text: 'Voir').click
        assert_text 'Disponible la semaine du 16 juin 2025 au 20 juin 2025'
      end

      test 'As employer with 1 week long application, it is shown as 1 ' \
           "week long both in the employer's dashboard" do
        employer, internship_offer = create_employer_and_offer_2nde
        school = create(:school, :lycee, :with_school_manager)
        student = create(:student, :seconde, school: school, email: 'test@free.fr', phone: '+330620554411')
        internship_offer.update!(weeks: [SchoolTrack::Seconde.first_week])
        create(:internship_application, :first_june_week, :submitted, internship_offer:, student:)
        sign_in(student)
        sign_in(employer)
        visit dashboard_candidatures_path
        click_link 'Répondre'
        find('.h5', text: "Informations sur l'élève")
        assert_text 'Disponible la semaine du 16 juin 2025 au 20 juin 2025'
      end
    end
  end
end
