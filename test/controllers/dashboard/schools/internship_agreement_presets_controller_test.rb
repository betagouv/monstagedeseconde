# frozen_string_literal: true

require 'test_helper'

module Dashboard
  module Schools
    class StudentsControllerTest < ActionDispatch::IntegrationTest
      include Devise::Test::IntegrationHelpers

      #
      # update by group
      #
      test 'GET edit as SchoolManager access full form' do
        school = create(:school, :with_school_manager, :with_agreement_presets)
        sign_in(school.school_manager)

        get edit_dashboard_school_internship_agreement_preset_path(school_id: school, id: school.internship_agreement_preset)
        assert_response :success
      end
    end
  end
end
