# frozen_string_literal: true

require 'test_helper'

class SchoolTest < ActiveSupport::TestCase
  def setup
    # create(:department, name: 'Paris')
  end
  test 'coordinates' do
    school = School.new
    assert school.invalid?
    assert_not_empty school.errors[:coordinates]
    assert_not_empty school.errors[:zipcode]
    assert_nil school.legal_status
  end

  test 'Agreement association' do
    school = create(:school, :with_school_manager)
    student = create(:student, :troisieme_generale, school:)
    internship_application = create(:weekly_internship_application, user_id: student.id)
    internship_agreement = create(:internship_agreement, :created_by_system,
                                  internship_application:)

    assert school.internship_agreements.include?(internship_agreement)
  end

  test 'legal_status' do
    school = create(:school)
    assert_equal 'Public', school.legal_status
    school.update(contract_code: '30', is_public: false)
    assert_equal 'Privé sous contrat', school.legal_status
  end

  test 'Users associations' do
    school = create(:school)

    student = create(:student, school:)
    school_manager = create(:school_manager, school:)
    main_teacher = create(:main_teacher, school:)
    teacher = create(:teacher, school:)

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
    teacher = create(:teacher, school:)
    assert school.has_staff?
  end

  test 'has_staff with only main_teacher' do
    school = create(:school, :with_school_manager)
    main_teacher = create(:main_teacher, school:)
    assert school.has_staff?
  end

  test 'has_staff with only other' do
    school = create(:school, :with_school_manager)
    other = create(:other, school:)
    assert school.has_staff?
  end

  test 'has_staff with all kind of staff' do
    school = create(:school, :with_school_manager)
    main_teacher = create(:main_teacher, school:)
    other = create(:other, school:)
    teacher = create(:teacher, school:)
    assert school.has_staff?
  end

  test 'uniq code_uai' do
    school = create(:school)
    assert school.valid?

    school_2 = build(:school, code_uai: school.code_uai)
    assert school_2.invalid?
    assert_not_empty school_2.errors[:code_uai]
  end

  test '.nearby_school_weeks' do
    travel_to Date.new(2019, 9, 1) do
      school_paris = create(:school, :at_paris, weeks: [Week.first]) # Paris
      school_bordeaux = create(:school, :at_bordeaux, weeks: Week.first(3))

      assert (school_bordeaux.coordinates.longitude - school_paris.coordinates.longitude).abs > 0.01
      assert (school_bordeaux.coordinates.latitude - school_paris.coordinates.longitude).abs > 0.04

      latitude = school_paris.coordinates.latitude
      longitude = school_paris.coordinates.longitude

      assert_equal ["school-week-#{Week.first.id}".to_sym],
                   School.nearby_school_weeks(latitude:, longitude:, radius: 60_000).keys
    end
  end

  test '.with_school_manager' do
    school = create(:school, :with_school_manager)
    assert_equal [school], School.with_school_manager
  end

  test 'select_text_method' do
    school = create(:school)
    assert_equal "#{school.name} - #{school.city} - #{school.zipcode}", school.select_text_method
  end

  test 'agreement_address' do
    school = create(:school)
    assert_equal "#{school.name} - #{school.city}, #{school.zipcode}", school.agreement_address
  end
end
