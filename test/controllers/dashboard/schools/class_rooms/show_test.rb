# frozen_string_literal: true

require 'test_helper'

module Dashboard
  module Schools
    class ShowClassRoomsTest < ActionDispatch::IntegrationTest
      include Devise::Test::IntegrationHelpers

      #
      # Student
      #
      test 'GET class_rooms#show as Student is forbidden' do
        school = create(:school)
        class_room = create(:class_room, school: school)
        sign_in(create(:student, school: school))

        get dashboard_school_class_room_path(school, class_room)
        assert_redirected_to root_path
      end

      #
      # Show, SchoolManagement
      #

      test 'GET class_rooms#show as SchoolManagement with weeks declared contains key navigations links' do
        school = create(:school, :with_school_manager)
        class_room = create(:class_room, school: school)
        teacher = create(:teacher, school: school, class_room: class_room)
        sign_in(teacher)

        get dashboard_school_class_room_students_path(school, class_room)
        assert_response :success
        assert_select 'li a[href=?]', dashboard_school_class_rooms_path(school), count: 1
        assert_select 'li a[href=?]', dashboard_school_users_path(school), count: 1
        assert_select 'li a[href=?]', dashboard_internship_agreements_path, count: 1
      end

      test 'GET class_rooms#show as SchoolManagement with no weeks declared contains key navigations links' do
        puts 'TODO'
      end
    end
  end
end
