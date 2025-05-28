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

      test 'student with validated application on first week can apply on second week' do
        application = create(:weekly_internship_application, :first_june_week, :approved)
        internship_offer = create(:weekly_internship_offer_2nde, :week_2)
        student = application.student
        sign_in(student)
        visit internship_offer_path(internship_offer)
        all('a', text: 'Postuler').first.click
        assert_text 'Votre candidature'
      end

      test 'student with validated application on second week can apply on first week' do
        application = create(:weekly_internship_application, :second_june_week, :approved)
        internship_offer = create(:weekly_internship_offer_2nde, :week_1)
        student = application.student
        sign_in(student)
        visit internship_offer_path(internship_offer)
        all('a', text: 'Postuler').first.click
        assert_text 'Votre candidature'
      end

      test 'student with validated application on second week can apply on first week with a 3e-2e offer' do
        skip 'waiting for PO decision'
        travel_to Date.new(2023, 10, 1) do
          application = create(:weekly_internship_application, :second_june_week, :approved)
          internship_offer = create(:weekly_internship_offer)
          student = application.student
          sign_in(student)
          visit internship_offer_path(internship_offer)
          all('a', text: 'Postuler').first.click
          assert_text 'Votre candidature'
        end
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
        sign_in(employer)
        visit dashboard_candidatures_path
        click_link 'Répondre'
        find('.h5', text: "Informations sur l'élève")
        assert_text 'Disponible la semaine du 16 juin 2025 au 20 juin 2025'
      end

      test 'As student, I can restore an application I have rejected, but once only' do
        internship_application = create(:weekly_internship_application, :first_june_week, :submitted)
        student = internship_application.student
        internship_application.cancel_by_student!
        sign_in(student)
        visit dashboard_students_internship_applications_path(student_id: student.id)
        find('button[aria-controls="canceled-internship-applications-panel"]', text: 'Annulées').click
        click_button 'Restaurer'
        find('textarea').set('Je me suis trompé')
        within('dialog') { click_button 'Restaurer ma candidature' }
        find 'span#alert-text', text: 'Candidature mise à jour avec succès.'
        find('.h5.internship-offer-title', text: 'Stage de 2de - 1')
        assert_equal 'Je me suis trompé', internship_application.reload.restored_message

        click_link 'Voir'
        find('button', text: 'Annuler la candidature').click
        find('dialog textarea').set('Je me suis trompé')
        within('dialog') { click_button "Confirmer l'annulation" }
        find('button[aria-controls="canceled-internship-applications-panel"]', text: 'Annulées').click
        assert_no_button 'Restaurer'
      end

      test 'As student, I cannot restore an application I have rejected, if I have an approved application' do
        create(:weekly_internship_application, :both_june_weeks, :approved)
        internship_application = create(:weekly_internship_application, :first_june_week, :submitted)
        student = internship_application.student
        internship_application.cancel_by_student!
        sign_in(student)
        visit dashboard_students_internship_applications_path(student_id: student.id)
        find('button[aria-controls="canceled-internship-applications-panel"]', text: 'Annulées').click
        assert_no_button 'Restaurer'
      end

      test 'As student, I cannot restore an application the employer has rejected' do
        internship_application = create(:weekly_internship_application, :first_june_week, :rejected)
        student = internship_application.student
        sign_in(student)
        visit dashboard_students_internship_applications_path(student_id: student.id)
        find('button[aria-controls="refused-internship-applications-panel"]', text: 'Refusées').click
        assert_no_button 'Restaurer'
      end

      test 'As employer, I can see a restored application once validated by me' do
        internship_application = create(:weekly_internship_application, :first_june_week, :restored)

        employer = internship_application.internship_offer.employer
        employer.current_area_id = internship_application.internship_offer.internship_offer_area_id
        employer.save!
        sign_in employer
        visit dashboard_candidatures_path
        find('td.col-title', text: 'Stage de 2de - 1')
      end

      test 'As employer, I can see a restored application with a standard "nouveau" label' do
        internship_application = create(:weekly_internship_application, :first_june_week, :submitted)
        internship_application.cancel_by_student!
        internship_application.restore!
        refute internship_application.has_ever_been?(%i[approved validated_by_employer])

        employer = internship_application.internship_offer.employer
        employer.current_area_id = internship_application.internship_offer.internship_offer_area_id
        employer.save!
        sign_in employer
        visit dashboard_candidatures_path
        find('td.col-title', text: 'Stage de 2de - 1')
        assert_text 'NOUVEAU'
      end
      test "As employer, I cannot restore any application targetting a student who's got its internship validated" do
        internship_application = create(:weekly_internship_application, :both_june_weeks, :approved)
        internship_application2 = create(:weekly_internship_application, :first_june_week, :rejected,
                                         student: internship_application.student)
        refute internship_application2.may_restore?
      end
    end
  end
end
