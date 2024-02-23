# frozen_string_literal: true

require 'application_system_test_case'

module Product
  class InternshipOfferStepperTest < ApplicationSystemTestCase
    include OrganisationFormFiller
    include InternshipOfferInfoFormFiller
    include TutorFormFiller

    test 'USE_W3C, new_dashboard_stepper_organisation_path' do
      employer = create(:employer)
      group = create(:group, name: 'hello', is_public: true)

      sign_in(employer)
      run_request_and_cache_response(report_as: 'new_dashboard_stepper_organisation_path') do
        visit new_dashboard_stepper_organisation_path
        fill_in_organisation_form(is_public: true, group: group)
      end
    end

    test 'USE_W3C, new_dashboard_stepper_internship_offer_info_path' do
      employer = create(:employer)
      organisation = create(:organisation, employer: employer)
      sector = create(:sector)
      sign_in(employer)

      travel_to(Date.new(2019, 3, 1)) do
        run_request_and_cache_response(report_as: 'new_dashboard_stepper_internship_offer_info_path') do
          visit new_dashboard_stepper_internship_offer_info_path(organisation_id: organisation.id)
          fill_in_internship_offer_info_form(sector: sector)
        end
      end
    end
  end
end
