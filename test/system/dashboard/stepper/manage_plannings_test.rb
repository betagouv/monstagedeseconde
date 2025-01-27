# frozen_string_literal: true

require 'application_system_test_case'
require 'sidekiq/testing'

class ManagePlanningsTest < ApplicationSystemTestCase
  include Devise::Test::IntegrationHelpers
  include PlanningFormFiller

  test 'can create a planning with grade troisieme / quatrieme only' do
    travel_to Date.new(2025, 1, 1) do
      entreprise = create(:entreprise, :private)
      refute entreprise.is_public
      internship_occupation = entreprise.internship_occupation
      employer = internship_occupation.employer

      sign_in(employer)
      visit new_dashboard_stepper_planning_path(entreprise_id: entreprise.id)
      fill_in_planning_form(with_seconde: false, with_troisieme: true)
      # TODO: schools management
      # execute_script('document.querySelector("input[name=\'is_reserved\']").click()')
      # fill_in "Commune ou nom de l'établissement pour lequel le stage est reservé",
      #         with: school.city
      # sleep 1
      # find('#downshift-0-item-0').click
      # select("Lycée evariste Gallois", from: "Établissement")

      assert_difference('Planning.count') do
        assert_difference('InternshipOffers::WeeklyFramed.count') do
          find("button[type='submit']").click
          notice = find('span#alert-text').text
          assert_match 'Votre offre est publiée', notice
        end
      end

      planning = Planning.last
      assert_equal entreprise.id, planning.entreprise_id
      assert_equal Grade.troisieme_et_quatrieme.ids.sort, planning.grades.map(&:id).sort
      assert_equal Week.troisieme_selectable_weeks.pluck(:id).sort,
                   planning.weeks.pluck(:id).sort
      assert_equal 'test de lunch break', planning.lunch_break
      refute SchoolTrack::Seconde.first_week.id.in?(planning.weeks.pluck(:id))
      refute SchoolTrack::Seconde.second_week.id.in?(planning.weeks.pluck(:id))
      assert_equal ['08:00', '15:00'], planning.weekly_hours

      internship_offer = InternshipOffer.last
      assert_equal planning.id, internship_offer.planning_id
      assert_equal employer.id, internship_offer.employer_id
      assert_equal 10, internship_offer.max_candidates
      assert_equal 1, internship_offer.max_students_per_group
      assert_equal 'test de lunch break', internship_offer.lunch_break
      assert_equal Coordinates.paris[:latitude], internship_offer.coordinates.latitude
      assert_equal Coordinates.paris[:longitude], internship_offer.coordinates.longitude
      assert_equal Coordinates.paris[:latitude], internship_offer.entreprise_coordinates.latitude
      assert_equal Coordinates.paris[:longitude], internship_offer.entreprise_coordinates.longitude
      assert_equal '75012', internship_offer.zipcode
      assert_equal 'Paris', internship_offer.city
      refute internship_offer.is_public
    end
  end

  test 'can create a planning with grade seconde only' do
    travel_to Date.new(2025, 1, 1) do
      entreprise = create(:entreprise, :private)
      refute entreprise.is_public
      internship_occupation = entreprise.internship_occupation
      employer = internship_occupation.employer

      sign_in(employer)
      visit new_dashboard_stepper_planning_path(entreprise_id: entreprise.id)
      fill_in_planning_form(with_troisieme: false, max_candidates: 1, first_week: true)
      # TODO: schools management
      # execute_script('document.querySelector("input[name=\'is_reserved\']").click()')
      # fill_in "Commune ou nom de l'établissement pour lequel le stage est reservé",
      #         with: school.city
      # sleep 1
      # find('#downshift-0-item-0').click
      # select("Lycée evariste Gallois", from: "Établissement")

      assert_difference('Planning.count') do
        assert_difference('InternshipOffers::WeeklyFramed.count') do
          find("button[type='submit']").click
          notice = find('span#alert-text').text
          assert_match 'Votre offre est publiée', notice
        end
      end

      planning = Planning.last
      assert_equal entreprise.id, planning.entreprise_id
      assert_equal [Grade.seconde.id], planning.grades.map(&:id).sort
      assert_equal 'test de lunch break', planning.lunch_break
      assert SchoolTrack::Seconde.first_week.id.in?(planning.weeks.pluck(:id))
      refute SchoolTrack::Seconde.second_week.id.in?(planning.weeks.pluck(:id))
      refute(SchoolTrack::Troisieme.selectable_from_now_until_end_of_school_year.pluck(:id).any? do |id|
        id.in?(planning.weeks.pluck(:id))
      end)
      assert_equal ['08:00', '15:00'], planning.weekly_hours

      internship_offer = InternshipOffer.last
      assert_equal planning.id, internship_offer.planning_id
      assert_equal employer.id, internship_offer.employer_id
      assert_equal 1, internship_offer.max_candidates
      assert_equal 1, internship_offer.max_students_per_group
      assert_equal 'test de lunch break', internship_offer.lunch_break
      assert_equal Coordinates.paris[:latitude], internship_offer.coordinates.latitude
      assert_equal Coordinates.paris[:longitude], internship_offer.coordinates.longitude
      assert_equal Coordinates.paris[:latitude], internship_offer.entreprise_coordinates.latitude
      assert_equal Coordinates.paris[:longitude], internship_offer.entreprise_coordinates.longitude
      assert SchoolTrack::Seconde.first_week.id.in?(internship_offer.weeks.pluck(:id))
      refute SchoolTrack::Seconde.second_week.id.in?(internship_offer.weeks.pluck(:id))
      refute(SchoolTrack::Troisieme.selectable_from_now_until_end_of_school_year.pluck(:id).any? do |id|
        id.in?(internship_offer.weeks.pluck(:id))
      end)
      assert_equal '75012', internship_offer.zipcode
      assert_equal 'Paris', internship_offer.city
      refute internship_offer.is_public
    end
  end

  test 'can create a planning with grade troisieme and seconde' do
    travel_to Date.new(2025, 1, 1) do
      entreprise = create(:entreprise, :private)
      refute entreprise.is_public
      internship_occupation = entreprise.internship_occupation
      employer = internship_occupation.employer

      sign_in(employer)
      visit new_dashboard_stepper_planning_path(entreprise_id: entreprise.id)
      fill_in_planning_form(
        with_troisieme: true,
        with_seconde: true,
        max_candidates: 4,
        first_week: true,
        all_year_long: true
      )
      # TODO: schools management
      # execute_script('document.querySelector("input[name=\'is_reserved\']").click()')
      # fill_in "Commune ou nom de l'établissement pour lequel le stage est reservé",
      #         with: school.city
      # sleep 1
      # find('#downshift-0-item-0').click
      # select("Lycée evariste Gallois", from: "Établissement")

      assert_difference('Planning.count') do
        assert_difference('InternshipOffers::WeeklyFramed.count') do
          find("button[type='submit']").click
          notice = find('span#alert-text').text
          assert_match 'Votre offre est publiée', notice
        end
      end

      planning = Planning.last
      refute planning.maintenance_conditions?
      assert_equal entreprise.id, planning.entreprise_id
      assert_equal Grade.all.map(&:id).sort, planning.grades.map(&:id).sort
      assert_equal 'test de lunch break', planning.lunch_break
      assert SchoolTrack::Seconde.first_week.id.in?(planning.weeks.pluck(:id))
      refute SchoolTrack::Seconde.second_week.id.in?(planning.weeks.pluck(:id))
      assert(SchoolTrack::Troisieme.selectable_from_now_until_end_of_school_year.pluck(:id)[1..-1].all? do |id|
        id.in?(planning.weeks.pluck(:id))
      end)
      assert_equal ['08:00', '15:00'], planning.weekly_hours

      internship_offer = InternshipOffer.last
      assert_equal planning.id, internship_offer.planning_id
      assert_equal employer.id, internship_offer.employer_id
      assert_equal 4, internship_offer.max_candidates
      assert_equal 1, internship_offer.max_students_per_group
      assert_equal 'test de lunch break', internship_offer.lunch_break
      assert_equal Coordinates.paris[:latitude], internship_offer.coordinates.latitude
      assert_equal Coordinates.paris[:longitude], internship_offer.coordinates.longitude
      assert_equal Coordinates.paris[:latitude], internship_offer.entreprise_coordinates.latitude
      assert_equal Coordinates.paris[:longitude], internship_offer.entreprise_coordinates.longitude
      assert SchoolTrack::Seconde.first_week.id.in?(internship_offer.weeks.pluck(:id))
      refute SchoolTrack::Seconde.second_week.id.in?(internship_offer.weeks.pluck(:id))
      assert(SchoolTrack::Troisieme.selectable_from_now_until_end_of_school_year.pluck(:id)[1..-1].all? do |id|
        id.in?(internship_offer.weeks.pluck(:id))
      end)
      assert_equal '75012', internship_offer.zipcode
      assert_equal 'Paris', internship_offer.city
      refute internship_offer.is_public
    end
  end

  test 'fails gracefully when both grades are unchecked' do
    travel_to Date.new(2025, 1, 1) do
      entreprise            = create(:entreprise)
      internship_occupation = entreprise.internship_occupation
      employer              = internship_occupation.employer

      sign_in(employer)
      visit new_dashboard_stepper_planning_path(entreprise_id: entreprise.id)
      assert_no_difference('Planning.count') do
        fill_in_planning_form(with_seconde: false, with_troisieme: false)
        find("button[type='submit']").click
      end
      within('.fr-alert.fr-alert--error.server-error') do
        find 'strong', text: /Niveaux ciblés/
      end
    end
  end

  test 'another employer cannot see the planning page' do
    travel_to Date.new(2025, 1, 1) do
      entreprise = create(:entreprise)
      employer = create(:employer)

      sign_in(employer)
      visit new_dashboard_stepper_planning_path(entreprise_id: entreprise.id)
      assert_text "Vous n'êtes pas autorisé à effectuer cette action"
    end
  end
  test 'can create a planning with seconde grade only' do
  end
  test 'can create a planning with all grades' do
  end

  test 'planning shows the right amount of schools nearby the entreprise' do
    travel_to Date.new(2019, 9, 1) do
      first_3_weeks = Week.selectable_from_now_until_end_of_school_year.first(3)
      school_bordeaux = create(:school, city: 'Bordeaux', zipcode: '33000',
                                        weeks: first_3_weeks, coordinates: Coordinates.bordeaux)
      school_paris = create(:school, city: 'Paris', zipcode: '75001',
                                     weeks: [first_3_weeks.first])
      internship_occupation = create(:internship_occupation, city: 'Paris', zipcode: '75001',
                                                             coordinates: Coordinates.paris)
      entreprise = create(:entreprise, internship_occupation:)
      assert internship_occupation.coordinates.latitude == Coordinates.paris[:latitude]
      assert internship_occupation.coordinates.longitude == Coordinates.paris[:longitude]
      sign_in(internship_occupation.employer)
      visit new_dashboard_stepper_planning_path(entreprise_id: entreprise.id)
      find('label[for="planning_all_year_long_false"]').click
      assert find("label[for='planning_week_ids_#{first_3_weeks.first.id}_checkbox']").text.match(/disponible/)
      refute find("label[for='planning_week_ids_#{first_3_weeks.last.id}_checkbox']").text.match(/disponible/)
    end
  end
end
