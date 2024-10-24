# frozen_string_literal: true

require 'test_helper'

module InternshipApplications
  class SetToReadTest < ActionDispatch::IntegrationTest
    include Devise::Test::IntegrationHelpers

    test 'PATCH #set_to_read as employer create a state change' do
      employer = create(:employer)
      internship_application = create(:weekly_internship_application, :submitted)
      assert_equal 1, internship_application.state_changes.count
      sign_in(employer)
      patch set_to_read_dashboard_internship_offer_internship_application_path(internship_application.internship_offer,
                                                                               internship_application)
      assert_response :redirect
      assert_equal 'read_by_employer', internship_application.reload.aasm_state
      assert_equal 2, internship_application.state_changes.count
      assert_equal employer, internship_application.state_changes.last.author
    end
  end
end
