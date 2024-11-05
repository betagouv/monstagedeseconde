# frozen_string_literal: true

require 'test_helper'

module Dashboard::Stepper
  class PlanningsControllerTest < ActionDispatch::IntegrationTest
    include Devise::Test::IntegrationHelpers

    test 'GET new not logged redirects to sign in' do
      get new_dashboard_stepper_planning_path
      assert_redirected_to user_session_path
    end

    test 'post a valid planning form' do
      travel_to Date.new(2025, 1, 1) do
        employer = create(:employer)
        school = create(:school, city: 'Paris', zipcode: '75001')
        internship_occupation = create(:internship_occupation, employer:)
        entreprise = create(:entreprise, internship_occupation:)

        assert entreprise.internship_occupation.present?
        weeks = Week.selectable_from_now_until_end_of_school_year

        sign_in(employer)
        planning = {
          all_year_long: true,
          grade_college: '1',
          grade_2e: '0',
          max_candidates: 10,
          max_students_per_group: 2,
          week_ids: weeks.ids,
          lunch_break: 'test de lunch break',
          daily_hours: {
            'lundi' => ['08:00', '15:00'],
            'mardi' => ['08:00', '13:00'],
            'mercredi' => ['09:00', '14:00'],
            'jeudi' => ['10:00', '15:00'],
            'vendredi' => ['11:00', '16:00']
          },
          school_id: school.id
        }

        assert_difference('Planning.count') do
          assert_difference('InternshipOffers::WeeklyFramed.count') do
            post(
              dashboard_stepper_plannings_path(entreprise_id: entreprise.id),
              params: { planning: }
            )
            internship_offer = InternshipOffer.last
            assert internship_offer.persisted?
            assert_redirected_to internship_offer_path(internship_offer.id, origine: 'dashboard', stepper: true)
            assert_match(/Votre offre est publiée/, flash[:notice])

            planning = Planning.last
            assert_equal 21, planning.weeks_count
            assert_equal 10, planning.max_candidates
            assert_equal 2, planning.max_students_per_group, 'should have 2 students per group'
            assert_equal 'test de lunch break', planning.lunch_break
            assert_equal 2, planning.grades.count, 'should have 2 grades'
            assert_equal 5, planning.max_candidates / planning.max_students_per_group
            assert_equal weeks.map(&:id).sort, planning.weeks.map(&:id).sort
            assert_equal school.id, planning.school_id
            assert_equal '08:00', planning.daily_hours['lundi'].first
            assert_equal employer.id, planning.employer_id
            assert_equal 1, planning.internship_weeks_number
          end
        end
      end
    end

    test 'post a valid planning form with weeky_hours' do
      travel_to Date.new(2025, 1, 1) do
        employer = create(:employer)
        internship_occupation = create(:internship_occupation, employer:)
        entreprise = create(:entreprise, internship_occupation:)
        assert entreprise.internship_occupation.present?
        weeks = SchoolTrack::Seconde.both_weeks

        sign_in(employer)
        planning = {
          all_year_long: true,
          grade_college: '0',
          grade_2e: '1',
          period: '2',
          max_candidates: 10,
          max_students_per_group: 5,
          week_ids: weeks.map(&:id),
          lunch_break: 'test de lunch break',
          daily_hours: {
            'lundi' => ['08:00', '15:00'],
            'mardi' => ['08:00', '13:00'],
            'mercredi' => ['09:00', '14:00'],
            'jeudi' => ['10:00', '15:00'],
            'vendredi' => ['11:00', '16:00']
          }
        }

        assert_difference('Planning.count') do
          assert_difference('InternshipOffers::WeeklyFramed.count') do
            post(
              dashboard_stepper_plannings_path(entreprise_id: entreprise.id),
              params: { planning: }
            )
            # assert_redirected_to dashboard_internship_offer_path(Planning.last.internship_offer_id)
            assert_match(/Votre offre est publiée/, flash[:notice])

            planning = Planning.last
            assert_equal 2, planning.weeks_count
            assert_equal 10, planning.max_candidates
            assert_equal 5, planning.max_students_per_group, 'should have 2 students per group'
            assert_equal 'test de lunch break', planning.lunch_break
            assert_equal 1, planning.grades.count, 'should have 2 grades'
            assert_equal 2, planning.max_candidates / planning.max_students_per_group
            assert_equal '08:00', planning.daily_hours['lundi'].first
            assert_equal weeks.map(&:id).sort, planning.weeks.map(&:id).sort
            assert_equal 2, planning.internship_weeks_number
          end
        end
      end
    end
  end
end
