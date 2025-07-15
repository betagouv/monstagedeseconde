# frozen_string_literal: true

require 'test_helper'

module InternshipApplications
  class ShowTest < ActionDispatch::IntegrationTest
    include Devise::Test::IntegrationHelpers

    test 'GET #show renders weekly_internship_application preview for student owning internship_application' do
      travel_to Date.new(2023, 10, 1) do
        internship_offer = create(:weekly_internship_offer_3eme)
        internship_application = create(:weekly_internship_application, :submitted, internship_offer:)
        sign_in(internship_application.student)
        get internship_offer_internship_application_path(internship_offer,
                                                         uuid: internship_application.uuid)
        assert_response :success
        assert_select 'title', 'Ma candidature | 1Elève1Stage'

        assert_select "form[action=\"#{internship_offer_internship_application_path(internship_offer,
                                                                                    uuid: internship_application.uuid, transition: :submit!)}\"]"
        assert_select "#submit_application_form[method='post'] input[name='_method'][value='patch']"
        assert_select '.student-email', internship_application.student_email
        assert_select '.student-phone', internship_application.student_phone
      end
    end

    test 'GET #show not owning internship_application is forbidden' do
      travel_to Date.new(2023, 10, 1) do
        internship_offer = create(:weekly_internship_offer_3eme)
        internship_application = create(:weekly_internship_application, :submitted, internship_offer:)
        sign_in(create(:student))
        get internship_offer_internship_application_path(internship_offer,
                                                         uuid: internship_application.uuid)
        assert_response :redirect
      end
    end

    test 'GET #show renders preview for school_manager' do
      travel_to Date.new(2023, 10, 1) do
        school = create(:school, :with_school_manager)
        class_room = create(:class_room, school:)
        student = create(:student, class_room:, school:)
        teacher = create(:teacher, class_room:, school:)
        internship_offer = create(:weekly_internship_offer_3eme)
        internship_application = create(:weekly_internship_application, :submitted, internship_offer:,
                                                                                    student:)
        sign_in(teacher)
        get internship_offer_internship_application_path(internship_offer,
                                                         uuid: internship_application.uuid)
        assert_response :success
        assert_select "form[action=\"#{internship_offer_internship_application_path(internship_offer,
                                                                                    uuid: internship_application.uuid, transition: :submit!)}\"]"
        assert_select "#submit_application_form[method='post'] input[name='_method'][value='patch']"
      end
    end
  end
end
