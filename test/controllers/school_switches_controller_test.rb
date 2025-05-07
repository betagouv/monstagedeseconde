require 'test_helper'
class SchoolSwitchesControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers
  include ThirdPartyTestHelpers

  setup do
    school_1 = create(:school)
    school_2 = create(:school)
    school_3 = create(:school)
    school_4 = create(:school)

    # Create school_manager with explicit school association
    @school_manager = create(:school_manager, role: 'school_manager', school: school_1)

    # Create UserSchool associations for other schools
    UserSchool.create!(user: @school_manager, school: school_2)
    UserSchool.create!(user: @school_manager, school: school_3)

    @school_1 = school_1
    @school_2 = school_2
    @school_3 = school_3
    @school_4 = school_4
  end

  test 'should switch_school' do
    sign_in @school_manager
    assert_equal @school_1.id, @school_manager.reload.school_id

    post school_switches_path, params: { school_id: @school_2.id }

    assert_response :redirect
    assert_equal @school_2.id, @school_manager.reload.school_id
    assert_equal @school_2, @school_manager.current_school
    assert_equal 3, @school_manager.schools.count
  end

  test 'should not switch school if user does not belong to school' do
    sign_in @school_manager
    assert_equal @school_1.id, @school_manager.reload.school_id

    post school_switches_path, params: { school_id: @school_4.id }
    assert_response :not_found
  end

  test 'school_manager switch school and school manager should be avalaibe for all schools' do
    student_1 = create(:student, school: @school_1)
    student_2 = create(:student, school: @school_2)
    student_3 = create(:student, school: @school_3)

    assert_equal 'school_manager', @school_manager.role, "School manager role should be 'school_manager'"
    assert_equal @school_manager, @school_1.school_manager, 'School 1 should have the correct school manager'
    assert_equal @school_manager, @school_2.school_manager, 'School 2 should have the correct school manager'
    assert_equal @school_manager, @school_3.school_manager, 'School 3 should have the correct school manager'

    assert_equal @school_manager, student_1.school.school_manager
    assert_equal @school_manager, student_2.school.school_manager
    assert_equal @school_manager, student_3.school.school_manager

    post school_switches_path, params: { school_id: @school_2.id }
    assert_response :redirect

    # Reload all objects to ensure we have fresh data
    student_1.reload
    student_2.reload
    student_3.reload
    @school_1.reload
    @school_2.reload
    @school_3.reload

    assert_equal @school_manager, student_1.school.school_manager
    assert_equal @school_manager, student_2.school.school_manager
    assert_equal @school_manager, student_3.school.school_manager
  end
end
