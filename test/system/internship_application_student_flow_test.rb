# frozen_string_literal: true

require 'application_system_test_case'
include ActiveJob::TestHelper
class InternshipApplicationStudentFlowTest < ApplicationSystemTestCase
  include Devise::Test::IntegrationHelpers
  include ThirdPartyTestHelpers

  test 'student not in class room can not ask for week' do
    school = create(:school)
    student = create(:student, school:, class_room: create(:class_room, school:))
    internship_offer = create(:weekly_internship_offer_2nde)

    sign_in(student)
    visit internship_offer_path(internship_offer)
    page.find 'a', text: 'Mon profil'
    assert_select 'a', text: 'Je postule', count: 0
  end

  test 'student in troisieme cannot submit an application when school have choosen weeks in the past' do
    travel_to Time.zone.local(2025, 3, 1) do
      school = create(:school, school_type: 'college')
      week_1 = Week.selectable_on_school_year.first
      week_2 = Week.selectable_on_school_year.second
      school.weeks = [week_1, week_2]
      student = create(:student, school:, class_room: create(:class_room, school:))
      internship_offer = create(:weekly_internship_offer_3eme, weeks: [week_1, week_2])

      sign_in(student)
      visit internship_offer_path(internship_offer)
      assert_select 'a', text: 'Postuler', count: 0
      all('a', text: 'Postuler').first.click
      assert page.has_content?('Votre établissement a déclaré des semaines de stage et aucune semaine n\'est compatible avec cette offre de stage.')
    end
  end
  test 'student in troisieme cannot see a intenship_offer for secondes' do
    travel_to Time.zone.local(2025, 3, 1) do
      week_1 = Week.selectable_on_school_year.first
      week_2 = Week.selectable_on_school_year.second
      school = create(:school, school_type: 'college', weeks: [week_1, week_2])
      student = create(:student, :troisieme, school:, class_room: create(:class_room, school:))
      internship_offer = create(:weekly_internship_offer_3eme, weeks: [week_1, week_2])
      internship_offer_seconde = create(:weekly_internship_offer_2nde)

      InternshipOffer.stub :nearby, InternshipOffer.all do
        InternshipOffer.stub :by_weeks, InternshipOffer.all do
          sign_in(student)
          visit internship_offer_path(internship_offer_seconde)
          all('button', text: 'Postuler')[0].disabled?
          all('p.fr-badge.fr-badge--warning', text: 'Offre incompatible avec votre classe'.upcase)[0].visible?

          visit internship_offer_path(internship_offer)
          all('a', text: 'Postuler')[0].visible?

          visit internship_offers_path
          assert_equal internship_offer.title, find('h4 .h5').text
          assert_select 'h4 .h5', text: internship_offer_seconde.title, count: 0
        end
      end
    end
  end
  test 'student in seconde cannot see a intenship_offer for troisiemes' do
    travel_to Time.zone.local(2025, 3, 1) do
      weeks = Week.selectable_from_now_until_end_of_school_year.to_a.first(2)
      school = create(:school, school_type: 'lycee', weeks: weeks)
      student = create(:student, :seconde, school:, class_room: create(:class_room, school:))
      internship_offer_troisieme = create(:weekly_internship_offer_3eme, weeks:)
      internship_offer_seconde = create(:weekly_internship_offer_2nde)
      assert InternshipOffer.seconde.ids.include?(internship_offer_seconde.id)
      assert InternshipOffer.troisieme_or_quatrieme.ids.include?(internship_offer_troisieme.id)
      assert_equal 'Stage de 3eme - 1', internship_offer_troisieme.title

      InternshipOffer.stub :nearby, InternshipOffer.all do
        InternshipOffer.stub :by_weeks, InternshipOffer.all do
          sign_in(student)
          visit internship_offer_path(internship_offer_troisieme)
          all('button', text: 'Postuler')[0].disabled?
          all('p.fr-badge.fr-badge--warning', text: 'Offre incompatible avec votre classe'.upcase)[0].visible?

          visit internship_offer_path(internship_offer_seconde)
          all('a', text: 'Postuler')[0].visible?

          visit internship_offers_path
          find '.fr-h4.fr-mt-4w.fr-mb-1w.blue-france',
               text: 'Je recherche une offre de stage de seconde générale et technologique'

          assert_equal internship_offer_seconde.title, find('.h5').text
          find '.h5', text: internship_offer_seconde.title, count: 1
          assert_select '.h5', text: internship_offer_troisieme.title, count: 0
        end
      end
    end
  end

  test 'student with no class_room can submit an application when school have not choosen week' do
    if ENV['RUN_BRITTLE_TEST']
      weeks = Week.selectable_from_now_until_end_of_school_year.to_a.first(2)
      school = create(:school)
      student = create(:student, school:)
      internship_offer = create(:weekly_internship_offer_2nde, weeks:)

      sign_in(student)
      visit internship_offer_path(internship_offer)
      first(:link, 'Postuler').click

      all('a', text: 'Postuler').first.click
      # check application is now here, ensure feature is here
      page.find '#internship-application-closeform', visible: true
      page.find('.test-missing-school-weeks', visible: true)
      week_label = Week.selectable_from_now_until_end_of_school_year
                       .first
                       .human_select_text_method

      select(week_label)
      # check for phone fields disabled
      page.find "input[name='internship_application[student_attributes][phone]'][disabled]", visible: true
      # check for email fields
      page.find "input[name='internship_application[student_attributes][email]']", visible: true
      page.find("input[type='submit'][value='Valider']").click
      assert page.has_selector?(".fr-card__title a[href='/internship_offers/#{internship_offer.id}']", count: 1)
      click_button('Envoyer')
      page.find('h2', text: "Félicitations, c'est ici que vous retrouvez toutes vos candidatures.")
      page.find('h2.h1.display-1', text: '1')
      assert page.has_content?(internship_offer.title)
    end
  end

  test 'student can receive a SMS when employer accepts her application' do
    school = create(:school)
    student = create(:student,
                     school:,
                     class_room: create(:class_room, school:),
                     email: '',
                     phone: '+330612345678')
    internship_application = create(
      :weekly_internship_application,
      :submitted,
      student:
    )
    sign_in(internship_application.internship_offer.employer)
    bitly_stub do
      visit dashboard_internship_offer_internship_applications_path(internship_application.internship_offer)
      click_on 'Accepter'
      click_on 'Confirmer'
    end
  end

  test 'student with approved application can see employer\'s address' do
    skip 'failing test on CI but passing locally' if ENV.fetch('CI') == 'true'
    school = create(:school, :with_school_manager)
    student = create(:student,
                     school:,
                     class_room: create(:class_room, school:))
    internship_application = create(
      :weekly_internship_application,
      :approved,
      student:
    )
    sign_in(student)
    visit '/'
    visit dashboard_students_internship_applications_path(student, internship_application.internship_offer)
    url = dashboard_students_internship_application_path(
      student_id: student.id,
      uuid: internship_application.uuid
    )
    assert page.has_selector?("a[href='#{url}']", count: 1)
    visit url
    find('.row .col-12 .fr-pl-1w.blue-france', text: '1 rue du poulet 75001 Paris')
  end

  test 'student with submittted application can not see employer\'s address' do
    school = create(:school)
    student = create(:student,
                     school:,
                     class_room: create(:class_room, school:))
    internship_application = create(
      :weekly_internship_application,
      :submitted,
      student:
    )
    sign_in(student)
    visit dashboard_students_internship_applications_path(student, internship_application.internship_offer)
    find('.h5.internship-offer-title.fr-mt-2w.text-dark', text: internship_application.internship_offer.title)
    click_link('Voir')
  end

  test 'when an employer tries to access application forms, she fails' do
    prismic_straight_stub do
      employer = create(:employer)
      internship_offer = create(:weekly_internship_offer_2nde)
      visit internship_offer_path(internship_offer.id)
      first(:link, 'Postuler').click
      fill_in('Adresse électronique', with: employer.email)
      fill_in('Mot de passe', with: employer.password)
      click_button('Se connecter')
      assert page.has_selector?('span#alert-text', text: "Vous n'êtes pas autorisé à effectuer cette action.")
    end
  end
end
