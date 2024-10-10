require 'test_helper'

module Admin
  class AdminControllerTest < ActionDispatch::IntegrationTest
    include Devise::Test::IntegrationHelpers

    test 'redirects to root path for all profile' do
      school = create(:school)
      school_manager = create(:school_manager, school:)
      roles = [create(:employer),
               create(:main_teacher, school:),
               create(:user_operator),
               create(:other, school:),
               create(:statistician),
               create(:student),
               create(:teacher, school:)]
      roles.each do |role|
        sign_in(role)
        get root_path
      end
    end

    test 'allows god to access admin_path' do
      god = create(:god)
      sign_in(god)
      get root_path
      assert_response :success
    end
  end
end
