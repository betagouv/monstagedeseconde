# frozen_string_literal: true

require 'test_helper'

module InternshipApplications
  class CreateTest < ActionDispatch::IntegrationTest
    include Devise::Test::IntegrationHelpers
    # include ActionMailer::TestHelper
    # include ThirdPartyTestHelpers

    test 'PUT #update/cancel as employer when application is submitted' do
      internship_application = create(:weekly_internship_application, :submitted)
      employer = internship_application.employer
      internship_application.internship_offer.employer_id = employer.id
      internship_application.internship_offer.save!
      internship_application.reload
      sign_in(internship_application.employer)

      params = {
        transition: :reject!,
        internship_application: {
          uuid: internship_application.uuid,
          cancel_reason: 'Motif de l\'annulation'
        }
      }

      put dashboard_internship_offer_internship_application_path(
        internship_application.internship_offer,
        uuid: internship_application.uuid
      ), params: params

      assert_redirected_to dashboard_candidatures_path(tab: 'reject!')
      internship_application.reload
      assert_equal 'rejected', internship_application.aasm_state
    end

    test 'PUT #update/cancel as student when application is cancelled it updates remaining seats' do
      internship_offer = create(:weekly_internship_offer, max_candidates: 3)
      internship_application = create(:weekly_internship_application, :approved, internship_offer:)
      employer = internship_application.employer
      student = internship_application.student
      internship_application.internship_offer.employer_id = employer.id
      internship_application.internship_offer.save!
      internship_application.reload
      # check application stats
      assert_equal 1, internship_application.internship_offer.remaining_seats_count
      sign_in(student)

      params = {
        transition: :cancel_by_student!,
        internship_application: {
          uuid: internship_application.uuid
        }
      }

      put dashboard_internship_offer_internship_application_path(
        internship_application.internship_offer,
        uuid: internship_application.uuid
      ), params: params

      internship_application.reload
      assert_equal 'canceled_by_student', internship_application.aasm_state
    end
  end
end
