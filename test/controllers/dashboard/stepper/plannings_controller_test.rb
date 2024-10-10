# frozen_string_literal: true

require 'test_helper'

module Dashboard::Stepper
  class PlanningsControllerTest < ActionDispatch::IntegrationTest
    include Devise::Test::IntegrationHelpers

    test 'post a valid planning form' do
      travel_to Date.new(2025, 1, 1) do
        employer = create(:employer)
        grade_3e = create(:grade, :troisieme)
        grade_4e = create(:grade, :quatrieme)
        internship_occupation = create(:internship_occupation, employer:)
        entreprise = create(:entreprise)
        sign_in(employer)
        planning = {
          internship_occupation_id: internship_occupation.id,
          entreprise_id: entreprise.id,
          all_year_long: true,
          grade_3e4e: true,
          max_candidates: 10,
          max_students_per_group: 2,
          weekly_lunch_break: 'test de lunch break'
        }

        assert_difference('Planning.count') do
          post(
            dashboard_stepper_plannings_path,
            params: { planning: }
          )
          # assert_redirected_to dashboard_internship_offer_path(Planning.last.internship_offer_id)
          assert_equal 'Les informations de planning ont bien été enregistrées. Votre offre est publiée', flash[:notice]

          planning = Planning.last
          assert_equal 26, planning.weeks_count
          assert_equal 10, planning.max_candidates
          assert_equal 2, planning.max_students_per_group, 'should have 2 students per group'
          assert_equal 'test de lunch break', planning.weekly_lunch_break
          assert_equal 2, planning.grades.count, 'should have 2 grades'
          assert_equal 5, planning.max_candidates / planning.max_students_per_group
        end
      end
    end
  end
end
