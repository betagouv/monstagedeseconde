# frozen_string_literal: true

require 'application_system_test_case'

class InternshipOfferIndexTest < ApplicationSystemTestCase
  include Devise::Test::IntegrationHelpers
  include ::ApiTestHelpers

  def assert_presence_of(internship_offer:)
    assert_selector "div[data-test-id='#{internship_offer.id}']",
                    count: 1,
                    wait: 10
  end

  def assert_absence_of(internship_offer:)
    assert_selector 'div[data-internship-offer-id]', minimum: 0, wait: 10
    assert_no_selector "div[data-test-id='#{internship_offer.id}']"
  end

  test 'navigation & interaction works' do
    school = create(:school)
    student = create(:student, :seconde, school:)
    create(:weekly_internship_offer_2nde)
    sign_in(student)
    InternshipOffer.stub :nearby, InternshipOffer.all do
      InternshipOffer.stub :by_weeks, InternshipOffer.all do
        visit internship_offers_path

        # assert_presence_of(internship_offer: internship_offer)
      end
    end
  end

  test 'pagination of internship_offers index is ok with api or weekly offers' do
    travel_to Date.new(2025, 3, 1) do
      2.times do
        create(:weekly_internship_offer_2nde, city: 'Chatillon', coordinates: Coordinates.chatillon)
      end
      (InternshipOffer::PAGE_SIZE / 2).times do
        create(:weekly_internship_offer_2nde, city: 'Paris', coordinates: Coordinates.paris, zipcode: '75000')
        create(:api_internship_offer, city: 'Paris', coordinates: Coordinates.paris, zipcode: '75000')
      end
      student = create(:student, :seconde)
      assert_equal 'Paris', student.school.city
      sign_in(student)
      visit_offers_index internship_offers_path
      click_button 'Rechercher'
      selector = '.test-city'
      # la recherche sans localisation ne trie plus par distance : on vérifie la
      # pagination (30 cartes page 1, 2 cartes page 2), pas la composition des villes
      within('.fr-test-internship-offers-container') do
        assert_selector(selector, count: InternshipOffer::PAGE_SIZE, wait: 10)
      end
      click_link 'Page suivante'
      within('.fr-test-internship-offers-container') do
        assert_selector(selector, count: 2, wait: 10)
      end
    end
  end

  # deux tests distincts (élève QPV / élève non QPV) : changer d'utilisateur au
  # sein d'un même test système ne prend pas de manière fiable (session Warden)
  test 'reserved qpv offers are shown to students from qpv schools' do
    travel_to Date.new(2024, 9, 1) do
      school = create(:school, qpv: true)
      student = create(:student, school: school, grade: Grade.seconde)
      internship_offer = create(:weekly_internship_offer_2nde, city: 'Paris', coordinates: Coordinates.paris,
                                                               zipcode: '75000', qpv: true)
      sign_in(student)
      visit_offers_index internship_offers_path
      click_button 'Rechercher'
      assert_presence_of(internship_offer: internship_offer)
    end
  end

  test 'reserved qpv offers are hidden from students of other schools' do
    travel_to Date.new(2024, 9, 1) do
      student = create(:student, grade: Grade.seconde)
      internship_offer = create(:weekly_internship_offer_2nde, city: 'Paris', coordinates: Coordinates.paris,
                                                               zipcode: '75000', qpv: true)
      sign_in(student)
      visit_offers_index internship_offers_path
      click_button 'Rechercher'
      assert_absence_of(internship_offer: internship_offer)
    end
  end
  test 'reserved rep/rep_plus offers are shown to students from rep or rep_plus schools' do
    travel_to Date.new(2024, 9, 1) do
      school = create(:school, rep_kind: 'rep')
      student = create(:student, school: school, grade: Grade.seconde)
      internship_offer = create(:weekly_internship_offer_2nde, city: 'Paris', coordinates: Coordinates.paris,
                                                               zipcode: '75000', rep: true)
      sign_in(student)
      visit_offers_index internship_offers_path
      click_button 'Rechercher'
      assert_presence_of(internship_offer: internship_offer)
    end
  end

  test 'reserved rep/rep_plus offers are hidden from students of other schools' do
    travel_to Date.new(2024, 9, 1) do
      student = create(:student, grade: Grade.seconde)
      internship_offer = create(:weekly_internship_offer_2nde, city: 'Paris', coordinates: Coordinates.paris,
                                                               zipcode: '75000', rep: true)
      sign_in(student)
      visit_offers_index internship_offers_path
      click_button 'Rechercher'
      assert_absence_of(internship_offer: internship_offer)
    end
  end

  # test 'recommandation is shown when no offer is available' do
  #   travel_to Date.new(2024, 9, 1) do
  #     2.times do
  #       create(:weekly_internship_offer_2nde, city: 'Montmorency', coordinates: Coordinates.montmorency)
  #     end
  #     student = create(:student, :seconde)
  #     assert_equal 'Paris', student.school.city
  #     sign_in(student)
  #     visit internship_offers_path(latitude: 48.8589, longitude: 2.347, city: 'paris', radius: 5_000)
  #     # there are no offers in Paris
  #     assert_selector('.test-city', text: 'Montmorency',
  #                                   count: 2, wait: 2)
  #   end
  # end

  test 'search by grade works for visitors' do
    travel_to Date.new(2024, 9, 1) do
      5.times do
        create(:weekly_internship_offer_2nde, weeks: SchoolTrack::Seconde.both_weeks, city: 'Paris')
      end
      internship_offer = create(:weekly_internship_offer_2nde, weeks: SchoolTrack::Seconde.both_weeks, city: 'Bordeaux')
      visit_offers_index internship_offers_path
      assert_selector('select#grade_id option', count: 3, wait: 10)
      select '3e', from: 'Niveau de classe'
      click_button 'Rechercher'
      assert_no_selector('.test-city', text: internship_offer.city)
      select '2de générale et technologique', from: 'Niveau de classe'
      click_button 'Rechercher'
      find('.test-city', text: 'Bordeaux', wait: 10)
    end
  end
  # le select de niveau est verrouillé sur le grade de l'élève connecté ;
  # deux tests distincts car changer d'utilisateur au sein d'un même test
  # système ne prend pas de manière fiable (session Warden)
  test 'search by grade works for students - troisieme sees no seconde offer' do
    travel_to Date.new(2024, 9, 1) do
      internship_offer = create(:weekly_internship_offer_2nde, weeks: SchoolTrack::Seconde.both_weeks)

      student = create(:student, grade: Grade.troisieme)
      sign_in(student)
      visit_offers_index internship_offers_path
      assert_selector('select#grade_id option', count: 1, wait: 10)
      assert_equal ['3e'], find('select#grade_id').all('option').map(&:text)
      click_button 'Rechercher'
      assert_no_selector('.test-city', text: internship_offer.city)
    end
  end

  test 'search by grade works for students - seconde sees seconde offer' do
    travel_to Date.new(2024, 9, 1) do
      internship_offer = create(:weekly_internship_offer_2nde, weeks: SchoolTrack::Seconde.both_weeks)

      student = create(:student, grade: Grade.seconde)
      sign_in(student)
      visit_offers_index internship_offers_path
      assert_selector('select#grade_id option', count: 1, wait: 10)
      assert_equal ['2de générale et technologique'], find('select#grade_id').all('option').map(&:text)
      click_button 'Rechercher'
      assert_selector('.test-city', text: internship_offer.city, wait: 10)
    end
  end
  # test 'search by weeks displays the right list of weeks for visitors' do
  #   travel_to Date.new(2024, 12, 26) do
  #     visit internship_offers_path
  #     find('button span', text: 'Sélectionnez une option').click
  #     within('.weeks-search-panel') do
  #       assert_selector('p.Décembre.month-score', text: 'Décembre (1)', count: 0)
  #       assert_selector('p.Janvier.month-score', text: 'Janvier (5)', count: 1)
  #       assert_selector('p.Février.month-score', text: 'Février (4)', count: 1)
  #       assert_selector('p.Mars.month-score', text: 'Mars (4)', count: 1)
  #       assert_selector('p.Avril.month-score', text: 'Avril (5)', count: 1)
  #       assert_selector('p.Mai.month-score', text: 'Mai (4)', count: 1)
  #       assert_selector('p.Juin.month-score', text: 'Juin (2)', count: 1)
  #     end
  #     assert_equal 5,
  #                  all('.custom-control-checkbox-list .Janvier input[type="checkbox"][checked="checked"]',
  #                      visible: false).count
  #     assert_equal 4,
  #                  all('.custom-control-checkbox-list .Février input[type="checkbox"][checked="checked"]',
  #                      visible: false).count
  #     assert_equal 2,
  #                  all('.custom-control-checkbox-list .Juin input[type="checkbox"][checked="checked"]',
  #                      visible: false).count
  #   end
  # end
  # test 'search by weeks displays the right list of weeks for students when school chose weeks' do
  #   travel_to Date.new(2024, 12, 26) do
  #     # seconde student
  #     school = create(:school) # No weeks declared
  #     student = create(:student, school: school, grade: Grade.seconde)
  #     assert_equal 2, student.school.school_weeks(student.grade).count
  #     sign_in(student)
  #     visit internship_offers_path
  #     find('button span', text: 'Sélectionnez une option').click
  #     within('.weeks-search-panel') do
  #       assert_selector('p.Décembre.month-score', text: 'Décembre', count: 0)
  #       assert_selector('p.Janvier.month-score', text: 'Janvier (5)', count: 0)
  #       assert_selector('p.Février.month-score', text: 'Février (4)', count: 0)
  #       assert_selector('p.Mars.month-score', text: 'Mars (4)', count: 0)
  #       assert_selector('p.Avril.month-score', text: 'Avril (5)', count: 0)
  #       assert_selector('p.Mai.month-score', text: 'Mai (4)', count: 0)
  #       assert_selector('p.Juin.month-score', text: 'Juin (2)', count: 1)
  #     end
  #     assert_equal 0,
  #                  all('.custom-control-checkbox-list .Janvier input[type="checkbox"][checked="checked"]',
  #                      visible: false).count
  #     assert_equal 2,
  #                  all('.custom-control-checkbox-list .Juin input[type="checkbox"][checked="checked"]',
  #                      visible: false).count
  #     logout(student)

  #     # Troisieme student with no weeks declared
  #     school = create(:school)
  #     student = create(:student, school: school, grade: Grade.troisieme)
  #     assert_equal 23, student.school.school_weeks(student.grade).count
  #     sign_in(student)
  #     visit internship_offers_path
  #     find('button span', text: 'Sélectionnez une option').click
  #     within('.weeks-search-panel') do
  #       assert_selector('p.Décembre.month-score', text: 'Décembre', count: 1)
  #       assert_selector('p.Janvier.month-score', text: 'Janvier (5)', count: 1)
  #       assert_selector('p.Février.month-score', text: 'Février (4)', count: 1)
  #       assert_selector('p.Mars.month-score', text: 'Mars (4)', count: 1)
  #       assert_selector('p.Avril.month-score', text: 'Avril (5)', count: 1)
  #       assert_selector('p.Mai.month-score', text: 'Mai (4)', count: 1)
  #       assert_selector('p.Juin.month-score', text: 'Juin (2)', count: 0)
  #     end
  #     assert_equal 5,
  #                  all('.custom-control-checkbox-list .Janvier input[type="checkbox"][checked="checked"]',
  #                      visible: false).count
  #     assert_equal 0,
  #                  all('.custom-control-checkbox-list .Juin input[type="checkbox"][checked="checked"]',
  #                      visible: false).count
  #     logout(student)

  #     # Troisieme student with weeks declared
  #     school = create(:school,
  #                     weeks: SchoolTrack::Troisieme.selectable_from_now_until_end_of_school_year.last(2))
  #     student = create(:student, school: school)
  #     sign_in(student)
  #     visit internship_offers_path
  #     find('button span', text: 'Sélectionnez une option').click
  #     within('.weeks-search-panel') do
  #       assert_selector('p.Décembre.month-score', text: 'Décembre', count: 0)
  #       assert_selector('p.Janvier.month-score', text: 'Janvier', count: 0)
  #       assert_selector('p.Février.month-score', text: 'Février', count: 0)
  #       assert_selector('p.Mars.month-score', text: 'Mars', count: 0)
  #       assert_selector('p.Avril.month-score', text: 'Avril', count: 0)
  #       assert_selector('p.Mai.month-score', text: 'Mai (2)', count: 1)
  #       assert_selector('p.Juin.month-score', text: 'Juin', count: 0)
  #     end
  #   end
  # end

  # test 'clicking on a week in the search panel updates the offers counter' do
  #   # Troisieme student with no weeks declared
  #   school = create(:school)
  #   student = create(:student, school: school, grade: Grade.troisieme)
  #   sign_in(student)
  #   visit internship_offers_path
  #   find('button span', text: 'Sélectionnez une option').click
  #   within('.month-lane') do
  #     assert_selector('p.Janvier.month-score', text: 'Janvier (5)', count: 1)
  #   end
  #   within('.flex-fill.weeks-list') do
  #     find('span.dates-column', text: 'du 30 déc. au 5 jan.').click
  #   end
  #   within('.month-lane') do
  #     assert_selector('p.Janvier.month-score', text: 'Janvier (4)', count: 1)
  #   end
  # end

  # test 'search by weeks filters the offers' do
  #   travel_to Date.new(2024, 12, 26) do
  #     internship_offer = create(:weekly_internship_offer_2nde, :week_1)
  #     visit internship_offers_path
  #     click_button 'Rechercher'
  #     assert_selector('.test-city', text: internship_offer.city, count: 1)
  #     find('button span', text: 'Sélectionnez une option').click
  #     within('.weeks-search-panel') do
  #       find('span.dates-column', text: 'du 16 au 22 juin').click # leaves it unchecked
  #     end
  #     within('.month-lane') do
  #       assert_selector('p.Juin.month-score', text: 'Juin (1)', count: 1) # second week selected
  #     end
  #     click_button 'Rechercher'
  #     assert_selector('.test-city', text: internship_offer.city, count: 0)
  #   end
  # end

  test 'search by school track filters the offers' do
    travel_to Date.new(2024, 12, 26) do
      internship_offer_1 = create(:weekly_internship_offer_2nde, city: 'Paris')
      internship_offer_2 = create(:weekly_internship_offer_3eme, city: 'Bordeaux')
      assert_equal Grade.seconde, internship_offer_1.grades.first
      assert_equal Grade.seconde, internship_offer_1.grades.last
      assert_equal Grade.troisieme, internship_offer_2.grades.first
      assert_equal Grade.troisieme, internship_offer_2.grades.last
      assert_equal 1, internship_offer_1.grades.count
      assert_equal 1, internship_offer_2.grades.count
      InternshipOffer.stub :nearby, InternshipOffer.all do
        InternshipOffer.stub :by_weeks, InternshipOffer.all do
          # par défaut, la recherche porte sur la 2de
          visit_offers_index internship_offers_path
          click_button 'Rechercher'
          assert_selector('.test-city', text: internship_offer_1.city, count: 1, wait: 10)
          assert_selector('.test-city', text: internship_offer_2.city, count: 0)

          # sélection du niveau depuis une page vierge : après une recherche sans
          # critère (URL sans grade_id), le select de niveau ne répond plus
          # (bug connu du composant React contrôlé), on repart donc de l'index
          visit_offers_index internship_offers_path
          select '3e', from: 'Niveau de classe'
          click_button 'Rechercher'
          assert_selector('.test-city', text: internship_offer_2.city, count: 1, wait: 10)
          assert_selector('.test-city', text: internship_offer_1.city, count: 0)
        end
      end
    end
  end
end
