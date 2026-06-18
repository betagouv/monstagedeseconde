# frozen_string_literal: true

require "test_helper"

module Admin
  class SchoolManagementsControllerTest < ActionDispatch::IntegrationTest
    include Devise::Test::IntegrationHelpers

    setup do
      @god   = create(:god)
      @school = create(:school)
      @school_management = create(:school_manager, school: @school)
    end

    # --- Authorization ---

    test "GET index redirects unauthenticated user" do
      get admin_school_managements_path
      assert_redirected_to user_session_path
    end

    test "GET index is not accessible for non-god users" do
      sign_in @school_management
      get admin_school_managements_path
      assert_response :redirect
    end

    # --- index ---

    test "GET index returns success for god" do
      sign_in @god
      get admin_school_managements_path
      assert_response :success
    end

    test "GET index with short query returns empty results" do
      sign_in @god
      get admin_school_managements_path, params: { query: "ab" }
      assert_response :success
      assert_equal Users::SchoolManagement.none.to_a, @controller.instance_variable_get(:@school_managements).to_a
    end

    test "GET index with query matching last_name returns results" do
      sign_in @god
      get admin_school_managements_path, params: { query: @school_management.last_name[0..3] }
      assert_response :success
      assert_includes @controller.instance_variable_get(:@school_managements), @school_management
    end

    test "GET index with query matching email returns results" do
      sign_in @god
      get admin_school_managements_path, params: { query: @school_management.email[0..5] }
      assert_response :success
      assert_includes @controller.instance_variable_get(:@school_managements), @school_management
    end

    test "GET index with query matching code_uai returns results" do
      sign_in @god
      get admin_school_managements_path, params: { query: @school.code_uai }
      assert_response :success
      assert_includes @controller.instance_variable_get(:@school_managements), @school_management
    end

    test "GET index with query matching nothing returns empty results" do
      sign_in @god
      get admin_school_managements_path, params: { query: "zzznomatch999" }
      assert_response :success
      assert_empty @controller.instance_variable_get(:@school_managements)
    end

    # --- show ---

    test "GET show returns success for god" do
      sign_in @god
      get admin_school_management_path(@school_management)
      assert_response :success
    end

    test "GET show exposes primary school and extra schools" do
      other_school = create(:school)
      UserSchool.create!(user: @school_management, school: other_school)

      sign_in @god
      get admin_school_management_path(@school_management)

      assert_equal @school, assigns(:primary_school)
      assert_includes assigns(:extra_schools), other_school
    end

    test "GET show with school_query returns matching schools" do
      other_school = create(:school, name: "Lycée unique zéta")
      sign_in @god
      get admin_school_management_path(@school_management), params: { school_query: "zéta" }
      assert_includes assigns(:schools), other_school
    end

    test "GET show excludes already associated schools from search" do
      associated_school = create(:school, name: "Lycée déjà associé")
      UserSchool.create!(user: @school_management, school: associated_school)

      sign_in @god
      get admin_school_management_path(@school_management),
          params: { school_query: "associé" }
      assert_not_includes assigns(:schools), associated_school
    end
    # --- switch_school ---

    test "PATCH switch_school cannot target a Student" do
      student = create(:student, school: @school)
      other_school = create(:school)
      UserSchool.create!(user: student, school: other_school)

      sign_in @god
      patch switch_school_admin_school_management_path(student),
            params: { school_id: other_school.id },
            as: :turbo_stream

      assert_response :not_found
    end

    test "PATCH switch_school is not accessible for non-god" do
      other_school = create(:school)
      UserSchool.create!(user: @school_management, school: other_school)

      sign_in @school_management
      patch switch_school_admin_school_management_path(@school_management),
            params: { school_id: other_school.id }

      assert_response :not_found
    end

    test "PATCH switch_school refuses school not in user_schools" do
      unrelated_school = create(:school)

      sign_in @god
      patch switch_school_admin_school_management_path(@school_management),
            params: { school_id: unrelated_school.id },
            as: :turbo_stream

      assert_response :unprocessable_entity
      assert_not_equal unrelated_school, @school_management.reload.current_school
    end

    test "PATCH switch_school changes current school for god" do
      other_school = create(:school)
      UserSchool.create!(user: @school_management, school: other_school)

      sign_in @god
      patch switch_school_admin_school_management_path(@school_management),
            params: { school_id: other_school.id },
            as: :turbo_stream

      assert_response :success
      assert_equal other_school, @school_management.reload.current_school
    end
  end
end
