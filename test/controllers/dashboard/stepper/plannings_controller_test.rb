# frozen_string_literal: true

require 'test_helper'

module Dashboard::Stepper
  class PlanningsControllerTest < ActionDispatch::IntegrationTest
    include Devise::Test::IntegrationHelpers

    test 'GET new not logged redirects to sign in' do
      get new_dashboard_stepper_planning_path
      assert_redirected_to user_session_path
    end

    test 'post a valid seconde planning form' do
      travel_to Date.new(2025, 1, 1) do
        employer = create(:employer)
        school = create(:school, city: 'Paris', zipcode: '75001')
        internship_occupation = create(:internship_occupation, employer:)
        entreprise = create(:entreprise, internship_occupation:)

        assert entreprise.internship_occupation.present?
        week_ids = [SchoolTrack::Seconde.first_week.id]

        sign_in(employer)
        planning = {
          all_year_long: true,
          grade_college: '0',
          grade_2e: '1',
          max_candidates: 2,
          max_students_per_group: 2,
          week_ids:,
          period: '11',
          lunch_break: 'test de lunch break',
          daily_hours: {
            'lundi' => ['08:00', '15:00'],
            'mardi' => ['08:00', '13:00'],
            'mercredi' => ['09:00', '14:00'],
            'jeudi' => ['10:00', '15:00'],
            'vendredi' => ['11:00', '16:00']
          },
          school_id: school.id,
          rep: true,
          qpv: true
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
            assert_equal 1, planning.weeks_count
            assert_equal 2, planning.max_candidates
            assert_equal 2, planning.max_students_per_group, 'should have 2 students per group'
            assert_equal 'test de lunch break', planning.lunch_break
            assert_equal 1, planning.grades.count, 'should have 2 grades'
            assert_equal 1, planning.max_candidates / planning.max_students_per_group
            assert_equal week_ids, [planning.weeks.first.id]
            assert_equal school.id, planning.school_id
            assert_equal '08:00', planning.daily_hours['lundi'].first
            assert_equal employer.id, planning.employer_id
            assert_equal SchoolTrack::Seconde.first_week.id, planning.weeks.first.id
            assert_equal true, planning.rep
            assert_equal true, planning.qpv
          end
        end
      end
    end
    test 'post a valid planning troisieme form' do
      travel_to Date.new(2025, 1, 1) do
        employer = create(:employer)
        school = create(:school, city: 'Paris', zipcode: '75001')
        internship_occupation = create(:internship_occupation, employer:)
        entreprise = create(:entreprise, internship_occupation:)

        assert entreprise.internship_occupation.present?
        week_ids = Week.troisieme_selectable_weeks.map(&:id)

        sign_in(employer)
        planning = {
          all_year_long: true,
          grade_college: '1',
          grade_2e: '0',
          max_candidates: 20,
          week_ids:,
          period: '11',
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
            assert_equal 20, planning.max_candidates
            assert_equal 20, planning.max_students_per_group, 'should have 2 students per group'
            assert_equal 'test de lunch break', planning.lunch_break
            assert_equal 2, planning.grades.count, 'should have 2 grades'
            assert_equal 1, planning.max_candidates / planning.max_students_per_group
            assert_equal week_ids.sort, planning.weeks.map(&:id).sort
            assert_equal school.id, planning.school_id
            assert_equal '08:00', planning.daily_hours['lundi'].first
            assert_equal employer.id, planning.employer_id
            assert_equal SchoolTrack::Troisieme.last_week_of_may.id, planning.weeks.to_a.sort_by(&:id).last.id
          end
        end
      end
    end
  end
end
