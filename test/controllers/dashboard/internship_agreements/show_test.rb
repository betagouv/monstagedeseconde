# frozen_string_literal: true

require 'test_helper'

module Dashboard::InternshipAgreements
  class ShowTest < ActionDispatch::IntegrationTest
    include Devise::Test::IntegrationHelpers
    include ActionMailer::TestHelper
    include TeamAndAreasHelper

    test 'Student can see internship agreement details' do
      school = create(:school, :with_school_manager)
      student = create(:student, school: school)

      employer, internship_offer = create_employer_and_offer_2nde
      internship_application = create(:weekly_internship_application, :approved, student: student,
                                                                                 internship_offer: internship_offer)
      internship_agreement = create(:internship_agreement, :validated, internship_application: internship_application)
      sign_in(student)

      get dashboard_internship_agreement_path(uuid: internship_agreement.uuid, format: :pdf)

      assert_response :success
    end
  end
end