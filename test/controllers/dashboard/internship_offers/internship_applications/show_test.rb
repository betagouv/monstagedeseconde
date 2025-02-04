# frozen_string_literal: true

require 'test_helper'

module InternshipApplications
  class ShowTest < ActionDispatch::IntegrationTest
    include Devise::Test::IntegrationHelpers

    test 'GET #show as employer' do
      internship_application = create(:weekly_internship_application, :submitted)
      sign_in(internship_application.internship_offer.employer)
      get dashboard_internship_offer_internship_application_path(internship_application.internship_offer,
                                                                 uuid: internship_application.uuid)

      assert_response :success
      internship_application.reload
      assert_equal 'read_by_employer', internship_application.aasm_state
    end

    test 'GET #show redirects to root_path when not logged in' do
      internship_application = create(:weekly_internship_application)
      get dashboard_internship_offer_internship_application_path(internship_application.internship_offer,
                                                                 uuid: internship_application.uuid)
      assert_redirected_to root_path
    end

    test 'GET #show redirects to root_path when token is wrong' do
      internship_application = create(:weekly_internship_application)
      get dashboard_internship_offer_internship_application_path(internship_application.internship_offer,
                                                                 uuid: internship_application.uuid,
                                                                 token: 'abc')
      assert_redirected_to root_path
    end
  end
end
