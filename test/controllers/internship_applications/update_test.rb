# frozen_string_literal: true

require 'test_helper'

module InternshipApplications
  class CreateTest < ActionDispatch::IntegrationTest
    include Devise::Test::IntegrationHelpers
    # include ActionMailer::TestHelper
    # include ThirdPartyTestHelpers

    test 'PUT #update/cancel as employer when application is submitted' do
      skip # Fix ability
      internship_application = create(:weekly_internship_application, :submitted)
      employer = internship_application.employer
      internship_application.internship_offer.employer_id = employer.id
      internship_application.internship_offer.save!
      internship_application.reload
      sign_in(internship_application.employer)


      params = {
        internship_application: {
          aasm_target: :cancel_by_employer!,
          cancel_reason: 'Motif de l\'annulation'
        }
      }

      put dashboard_internship_offer_internship_application_path(
        internship_application.internship_offer,
        internship_application
      ), params: params

      assert_redirected_to dashboard_candidatures_path
      
    end
  end
end
