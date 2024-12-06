# frozen_string_literal: true

require 'application_system_test_case'

module Product
  class InternshipOfferStepperTest < ApplicationSystemTestCase
    include InternshipOccupationFormFiller
    include EntrepriseFormFiller
    include PlanningFormFiller

    test 'USE_W3C, new_dashboard_stepper_internship_occupation_path' do
      employer = create(:employer)
      group = create(:group, name: 'hello', is_public: true)

      sign_in(employer)
      run_request_and_cache_response(report_as: 'new_dashboard_stepper_internship_occupation_path') do
        visit new_dashboard_stepper_internship_occupation_path
        fill_in_internship_occupation_form(is_public: true, group:)
      end
    end

    test 'USE_W3C, new_dashboard_stepper_entreprise_path' do
      employer = create(:employer)
      internship_occupation = create(:internship_occupation, employer:)
      sector = create(:sector)
      sign_in(employer)

      travel_to(Date.new(2024, 3, 1)) do
        run_request_and_cache_response(report_as: 'new_dashboard_stepper_entreprise_path') do
          visit new_dashboard_stepper_entreprise_path(internship_occupation_id: internship_occupation.id)
          fill_in_entreprise_form(sector:)
        end
      end
    end
    test 'USE_W3C, new_dashboard_stepper_planning_path' do
      employer = create(:employer)
      entreprise = create(:entreprise, employer:)
      sector = create(:sector)
      sign_in(employer)

      travel_to(Date.new(2024, 3, 1)) do
        run_request_and_cache_response(report_as: 'new_dashboard_stepper_planning_path') do
          visit new_dashboard_stepper_planning_path(entreprise_id: entreprise.id)
          fill_in_planning_form(sector:)
        end
      end
    end
  end
end
