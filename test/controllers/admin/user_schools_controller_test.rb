# frozen_string_literal: true

require "test_helper"

module Admin
  class UserSchoolsControllerTest < ActionDispatch::IntegrationTest
    include Devise::Test::IntegrationHelpers

    setup do
      @god              = create(:god)
      @school           = create(:school)
      @school_management = create(:school_manager, school: @school)
      @other_school     = create(:school)
    end

    # --- create ---

    test "POST create associates school and returns turbo_stream" do
      sign_in @god
      assert_difference "UserSchool.count", 1 do
        post admin_school_management_user_schools_path(@school_management),
             params: { school_id: @other_school.id },
             as: :turbo_stream
      end
      assert_response :success
    end

    test "POST create is idempotent – does not create duplicate" do
      UserSchool.create!(user: @school_management, school: @other_school)
      sign_in @god
      assert_no_difference "UserSchool.count" do
        post admin_school_management_user_schools_path(@school_management),
             params: { school_id: @other_school.id },
             as: :turbo_stream
      end
      assert_response :success
    end

    test "POST create is not accessible for non-god" do
      sign_in @school_management
      assert_no_difference "UserSchool.count" do
        post admin_school_management_user_schools_path(@school_management),
             params: { school_id: @other_school.id }
      end
      assert_response :not_found
    end

    # --- destroy ---

    test "DELETE destroy removes association and returns turbo_stream" do
      user_school = UserSchool.create!(user: @school_management, school: @other_school)
      sign_in @god
      assert_difference "UserSchool.count", -1 do
        delete admin_school_management_user_school_path(@school_management, user_school),
               as: :turbo_stream
      end
      assert_response :success
    end

    test "DELETE destroy is not accessible for non-god" do
      user_school = UserSchool.create!(user: @school_management, school: @other_school)
      sign_in @school_management
      assert_no_difference "UserSchool.count" do
        delete admin_school_management_user_school_path(@school_management, user_school)
      end
      assert_response :not_found
    end
  end
end
