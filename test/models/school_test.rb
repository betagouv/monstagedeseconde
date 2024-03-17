# frozen_string_literal: true

require 'test_helper'

class SchoolTest < ActiveSupport::TestCase
  test 'coordinates' do
    school = School.new
    assert school.invalid?
    assert_not_empty school.errors[:coordinates]
    assert_not_empty school.errors[:zipcode]
  end

  test 'Agreement association' do
    school = create(:school, :with_school_manager)
    student = create(:student, :troisieme_generale, school: school)
    internship_application = create(:weekly_internship_application, user_id: student.id)
    internship_agreement = create(:internship_agreement, :created_by_system,
                                  internship_application: internship_application)

    assert school.internship_agreements.include?(internship_agreement)
  end

  test 'Users associations' do
    school = create(:school)

    student = create(:student, school: school)
    school_manager = create(:school_manager, school: school)
    main_teacher = create(:main_teacher, school: school)
    teacher = create(:teacher, school: school)

    assert_equal [student], school.students.all
    assert_equal [main_teacher], school.main_teachers.all
    assert_equal [teacher], school.teachers.all
    assert_equal school_manager, school.school_manager
    assert_includes school.users, student
    assert_includes school.users, main_teacher
    assert_includes school.users, teacher
    assert_includes school.users, school_manager
  end

  test 'has_staff with only manager' do
    school = create(:school, :with_school_manager)
    refute school.has_staff?
  end

  test 'has_staff with only teacher' do
    school = create(:school, :with_school_manager)
    teacher = create(:teacher, school: school)
    assert school.has_staff?
  end

  test 'has_staff with only main_teacher' do
    school = create(:school, :with_school_manager)
    main_teacher = create(:main_teacher, school: school)
    assert school.has_staff?
  end

  test 'has_staff with only other' do
    school = create(:school, :with_school_manager)
    other = create(:other, school: school)
    assert school.has_staff?
  end

  test 'has_staff with all kind of staff' do
    school = create(:school, :with_school_manager)
    main_teacher = create(:main_teacher, school: school)
    other = create(:other, school: school)
    teacher = create(:teacher, school: school)
    assert school.has_staff?
  end

  
  test 'uniq code_uai' do
    school = create(:school)
    assert school.valid?

    school_2 = build(:school, code_uai: school.code_uai)
    assert school_2.invalid?
    assert_not_empty school_2.errors[:code_uai]
  end
end
