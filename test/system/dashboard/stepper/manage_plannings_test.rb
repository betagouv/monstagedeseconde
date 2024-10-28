# frozen_string_literal: true

require 'application_system_test_case'

class ManagePlanningsTest < ApplicationSystemTestCase
  include Devise::Test::IntegrationHelpers

  test 'can create a planning with grade troisieme / quatrieme only' do
    travel_to Date.new(2025, 1, 1) do
      entreprise = create(:entreprise, is_public: false)
      internship_occupation = entreprise.internship_occupation
      employer = internship_occupation.employer

      sign_in(employer)
      visit new_dashboard_stepper_planning_path(entreprise_id: entreprise.id)
      execute_script('document.getElementById("planning_all_year_long_true").click()')

      # default 'seconde' choice will be unchecked
      execute_script('document.getElementById("planning_grade_2e").click()')

      fill_in "Nombre total d'élèves que vous souhaitez accueillir sur la période de stage", with: 10
      find('#planning_weekly_hours_start').select('08:00')
      find('#planning_weekly_hours_end').select('15:00')
      fill_in 'Pause déjeuner', with: 'test de lunch break'
      execute_script('document.querySelector("input[name=\'is_reserved\']").click()')
      # TODO
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
      assert_equal Week.selectable_from_now_until_end_of_school_year.pluck(:id).sort,
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

  test 'fails gracefully when both grades are unchecked' do
    travel_to Date.new(2025, 1, 1) do
      entreprise = create(:entreprise)
      internship_occupation = entreprise.internship_occupation
      employer = internship_occupation.employer

      sign_in(employer)
      assert_no_difference('Planning.count') do
        visit new_dashboard_stepper_planning_path(entreprise_id: entreprise.id)
        execute_script('document.getElementById("planning_grade_3e4e").click()')
        execute_script('document.getElementById("planning_all_year_long_true").click()')
        execute_script('document.getElementById("planning_grade_2e").click()')

        fill_in 'Pause déjeuner', with: 'test de lunch break'

        find("button[type='submit']").click
      end
      within('.fr-alert.fr-alert--error') do
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
end
