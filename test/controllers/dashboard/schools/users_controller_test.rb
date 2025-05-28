# frozen_string_literal: true

require 'test_helper'

module Dashboard
  module Schools
    class UsersControllerTest < ActionDispatch::IntegrationTest
      include Devise::Test::IntegrationHelpers

      #
      # destroy
      #
      test 'DELETE #destroy not signed in' do
        school = create(:school, :with_school_manager)
        main_teacher = create(:main_teacher, school: school)

        delete dashboard_school_user_path(school, main_teacher)
        assert_redirected_to new_user_session_path
      end

      test 'DELETE #destroy as main_teacher fails' do
        school = create(:school, :with_school_manager)
        main_teacher = create(:main_teacher, school: school)
        sign_in(main_teacher)
        delete dashboard_school_user_path(school, main_teacher)
        assert_redirected_to root_path
      end

      test 'DELETE #destroy as SchoolManagement succeed' do
        school = create(:school, :with_school_manager)
        main_teacher = create(:main_teacher, school: school)
        sign_in(school.school_manager)
        assert_changes -> { main_teacher.reload.school } do
          delete dashboard_school_user_path(school, main_teacher)
        end
        assert_redirected_to dashboard_school_users_path(school)
      end

      #
      # index
      #
      test 'GET users#index as Student is forbidden' do
        school = create(:school)
        sign_in(create(:student))

        get dashboard_school_users_path(school)
        assert_redirected_to root_path
      end

      test 'GET users#index as Teacher when no schoolmanager works' do
        school = create(:school)
        teacher = create(:teacher, school: school)
        sign_in(teacher)

        get dashboard_school_users_path(school)
        assert_response :success
      end

      test 'GET users#index as SchoolManagement works' do
        school = create(:school, :with_school_manager)
        sign_in(school.school_manager)

        get dashboard_school_users_path(school)
        assert_response :success
      end

      test 'GET users#index as SchoolManagement contains key navigations links' do
        school = create(:school, :with_school_manager)
        sign_in(school.school_manager)

        get dashboard_school_users_path(school)
        assert_response :success
        assert_select 'title', "Professeurs du #{school.presenter.school_name_in_sentence} | 1élève1stage"
        assert_select 'ul.fr-tabs__list li a[href=?]', dashboard_school_class_rooms_path(school), count: 1
        assert_select 'ul.fr-tabs__list li a[href=?]', dashboard_school_users_path(school), count: 1
        assert_select 'ul.fr-tabs__list li a[href=?] button[aria-selected="false"]',
                      dashboard_school_class_rooms_path(school), count: 1
        assert_select 'ul.fr-tabs__list li a[href=?] button[aria-selected="true"]',
                      dashboard_school_users_path(school), count: 1
      end

      test 'GET users#index as SchoolManagement contains invitation modal link' do
        school = create(:school, :with_school_manager)
        sign_in(school.school_manager)
        get dashboard_school_users_path(school)
        assert_response :success
      end

      test 'GET users#index as SchoolManagement contains list school members' do
        school = create(:school, :with_school_manager)
        sign_in(school.school_manager)
        school_employees = [
          create(:main_teacher, school: school),
          create(:teacher, school: school),
          create(:other, school: school)
        ]

        get dashboard_school_users_path(school)
        assert_response :success
        assert_select 'tbody tr', count: school_employees.length + 1 # school manager
      end

      test 'PATCH claim_school_management as SchoolManagement with 2 ' \
           'admin_officers make the admin_officer become school_manager' do
        school = create(:school)
        admin_officer_1 = create(:admin_officer, school: school)
        admin_officer_2 = create(:admin_officer, school: school)
        sign_in(admin_officer_1)
        patch claim_school_management_dashboard_school_user_path(school_id: school.id, id: admin_officer_2.id)
        assert_redirected_to dashboard_school_users_path(school)
        assert_equal 'admin_officer', admin_officer_1.reload.role
        assert_equal 'school_manager', admin_officer_2.reload.role
      end

      test 'PATCH claim_school_management as SchoolManagement with 2 ' \
           'admin_officers make the admin_officer become school_manager - self claiming' do
        school = create(:school)
        admin_officer_1 = create(:admin_officer, school: school)
        admin_officer_2 = create(:admin_officer, school: school)
        sign_in(admin_officer_1)
        patch claim_school_management_dashboard_school_user_path(school_id: school.id, id: admin_officer_1.id)
        assert_redirected_to dashboard_school_users_path(school)
        assert_equal 'school_manager', admin_officer_1.reload.role
        assert_equal 'admin_officer', admin_officer_2.reload.role
      end

      test 'PATCH claim_school_management as SchoolManagement when current_user is teacher with ' \
           'admin_officers make the admin_officer become school_manager - self claiming' do
        school = create(:school)
        admin_officer_1 = create(:admin_officer, school: school)
        admin_officer_2 = create(:admin_officer, school: school)
        teacher = create(:teacher, school: school)
        sign_in(teacher)
        patch claim_school_management_dashboard_school_user_path(school_id: school.id, id: admin_officer_1.id)
        assert_redirected_to dashboard_school_users_path(school)
        assert_equal 'admin_officer', admin_officer_1.reload.role
        assert_equal 'admin_officer', admin_officer_2.reload.role
      end
    end
  end
end
