# frozen_string_literal: true

require 'test_helper'

module Dashboard
  module Schools
    class IndexClassRoomsTest < ActionDispatch::IntegrationTest
      include Devise::Test::IntegrationHelpers

      #
      # Index Student
      #
      test 'GET class_rooms#index as Student is forbidden' do
        school = create(:school)
        sign_in(create(:student, school: school))

        get dashboard_school_class_rooms_path(school)
        assert_redirected_to root_path
      end

      #
      # Index, SchoolManagement
      #
      test 'GET class_rooms#index as school school employees works' do
        school = create(:school)
        roles = [create(:school_manager, school: school),
                 create(:other, school: school),
                 create(:teacher, school: school)]
        roles.map do |role|
          sign_in(role)
          get dashboard_school_class_rooms_path(school)
          assert_response :success
        end
      end

      test 'GET class_rooms#index as SchoolManagement shows link to manage school' do
        school = create(:school, :college, :with_school_manager)

        sign_in(school.school_manager)
        get dashboard_school_class_rooms_path(school)
        assert_select 'li a[href=?]',
                      dashboard_school_users_path(school),
                      { count: 1 },
                      'missing link to manage school users'
      end

      test 'GET class_rooms#index contains key navigations links to manage school classroom' do
        school = create(:school, :with_school_manager)
        class_room_with_student = create(:class_room, school: school,
                                                      students: [create(:student)])
        class_room_without_student = create(:class_room, school: school,
                                                         students: [])
        roles = [create(:school_manager, school: school),
                 create(:other, school: school),
                 create(:teacher, school: school)]
        roles.map do |user|
          sign_in(user)
          role = user.type
          get dashboard_school_path(school)
          follow_redirect!
          assert_response :success

          assert_select 'a[href=?]',
                        dashboard_school_class_room_path(school, class_room_with_student),
                        { count: 0 }, # do not show destroy on classrooms with students,
                        "link to destroy class_room with student present for #{role}"
        end
      end

      test 'GET class_rooms#index shows class rooms list' do
        school = create(:school)
        class_rooms = [
          create(:class_room, school: school),
          create(:class_room, school: school),
          create(:class_room, school: school)
        ]
        roles = [create(:school_manager, school: school),
                 create(:other, school: school),
                 create(:teacher, school: school)]
        roles.map do |role|
          sign_in(role)

          get dashboard_school_class_rooms_path(school)
          class_rooms.map do |class_room|
            assert_select '.d-sm-none a[href=?]',
                          dashboard_school_class_room_students_path(school, class_room),
                          count: 1, text: 'Voir le détail'
            assert_select '.col-sm-12 a[href=?]',
                          dashboard_school_class_room_students_path(school, class_room),
                          count: 1, text: class_room.name

            stats = Presenters::Dashboard::ClassRoomStats.new(class_room: class_room)
            assert_select ".test-class-room-#{class_room.id} .total_student_with_zero_application",
                          text: stats.total_student_with_zero_application.to_s
            # assert_select ".test-class-room-#{class_room.id} .total_pending_convention_signed",
            #               text: stats.total_pending_convention_signed.to_s
            assert_select ".test-class-room-#{class_room.id} .total_student_with_zero_internship",
                          text: stats.total_student_with_zero_internship.to_s
          end
        end
      end

      test 'GET class_rooms#index shows N-1 switch buttons when user belongs to N schools, even after switching school' do
        school_1 = create(:school)
        school_2 = create(:school)
        school_3 = create(:school)

        school_manager = create(:school_manager, school: school_1)
        UserSchool.find_or_create_by!(user: school_manager, school: school_2)
        UserSchool.find_or_create_by!(user: school_manager, school: school_3)

        sign_in(school_manager)

        # Avant switch : connecté sur school_1, doit voir 2 boutons (school_2 et school_3)
        get dashboard_school_class_rooms_path(school_1)
        assert_response :success
        assert_select 'button[name="school_id"]', count: 2,
                      message: 'Doit afficher 2 boutons switch avant le premier switch'

        # Switch vers school_2
        post school_switches_path, params: { school_id: school_2.id }
        assert_redirected_to dashboard_school_class_rooms_path(school_2)
        follow_redirect!

        # Après switch : connecté sur school_2, doit voir 2 boutons (school_1 et school_3)
        assert_select 'button[name="school_id"]', count: 2,
                      message: 'Doit afficher 2 boutons switch après le switch vers school_2'
      end

      test 'GET class_rooms#index shows N-1 switch buttons even when current_school is not in user_schools' do
        school_1 = create(:school)
        school_2 = create(:school)
        school_3 = create(:school)

        # school_manager dont school_id = school_1, mais user_schools ne contient que school_2 et school_3
        # (simulate legacy data where school_id n'est pas dans user_schools)
        school_manager = create(:school_manager, school: school_1)
        UserSchool.where(user: school_manager, school: school_1).destroy_all
        UserSchool.find_or_create_by!(user: school_manager, school: school_2)
        UserSchool.find_or_create_by!(user: school_manager, school: school_3)

        sign_in(school_manager)

        get dashboard_school_class_rooms_path(school_1)
        assert_response :success
        assert_select 'button[name="school_id"]', count: 2,
                      message: 'Doit afficher 2 boutons même si current_school absent de user_schools'
      end

      test 'GET show as SchoolManagement works and only show not archived students' do
        school = create(:school)
        class_room = create(:class_room, school: school)
        student_in_class_room = create(:student, school: school, class_room: class_room)
        student_anonymized = create(:student, school: school, class_room: class_room, anonymized: true)
        student_not_in_class_room_not_anonymized = create(:student, school: school)
        student_not_in_class_room_not_anonymized.update(class_room_id: nil)

        sign_in(create(:school_manager, school: school))

        get dashboard_school_class_rooms_path(school)
        assert_response :success
        assert_select "div[data-test=\"student-not-in-class-room-#{student_in_class_room.id}\"]", count: 0
        assert_select "div[data-test=\"student-not-in-class-room-#{student_anonymized.id}\"]", count: 0
        assert_select "div[data-test=\"student-not-in-class-room-#{student_not_in_class_room_not_anonymized.id}\"]",
                      count: 1
      end
    end
  end
end
