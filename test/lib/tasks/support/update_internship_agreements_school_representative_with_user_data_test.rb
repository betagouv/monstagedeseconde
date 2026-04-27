require 'test_helper'

class UpdateInternshipAgreementsSchoolRepresentativeWithUserDataTest < ActiveSupport::TestCase
  TASK_NAME = 'support:update_internship_agreements_school_representative_with_user_data'

  Monstage::Application.load_tasks

  def invoke_task(user_id:, school_uai_code:, from_date:)
    Rake::Task[TASK_NAME].reenable
    Rake::Task[TASK_NAME].invoke(user_id, school_uai_code, from_date)
  end

  test 'updates school_representative fields with user email and full_name' do
    agreement = create(:mono_internship_agreement)
    student   = agreement.internship_application.student
    school    = student.school
    manager   = create(:school_manager, school: school)
    from_date = (agreement.created_at - 1.day).strftime('%d/%m/%Y')

    invoke_task(
      user_id:         manager.id,
      school_uai_code: school.code_uai,
      from_date:       from_date
    )

    agreement.reload
    assert_equal manager.email,                agreement.school_representative_email
    assert_equal manager.presenter.full_name,  agreement.school_representative_full_name
  end

  test 'does not update agreements created before from_date' do
    agreement = create(:mono_internship_agreement)
    student   = agreement.internship_application.student
    school    = student.school
    manager   = create(:school_manager, school: school)
    original_email = agreement.school_representative_email
    original_name  = agreement.school_representative_full_name
    from_date = (agreement.created_at + 1.day).strftime('%d/%m/%Y')

    invoke_task(
      user_id:         manager.id,
      school_uai_code: school.code_uai,
      from_date:       from_date
    )

    agreement.reload
    assert_equal original_email, agreement.school_representative_email
    assert_equal original_name,  agreement.school_representative_full_name
  end

  test 'does not update agreements belonging to another school' do
    agreement       = create(:mono_internship_agreement)
    other_agreement = create(:mono_internship_agreement)
    student         = agreement.internship_application.student
    school          = student.school
    manager         = create(:school_manager, school: school)
    original_email  = other_agreement.school_representative_email
    original_name   = other_agreement.school_representative_full_name
    from_date       = (agreement.created_at - 1.day).strftime('%d/%m/%Y')

    invoke_task(
      user_id:         manager.id,
      school_uai_code: school.code_uai,
      from_date:       from_date
    )

    other_agreement.reload
    assert_equal original_email, other_agreement.school_representative_email
    assert_equal original_name,  other_agreement.school_representative_full_name
  end

  test 'skips update when user_id is not found' do
    agreement = create(:mono_internship_agreement)
    original_email = agreement.school_representative_email

    invoke_task(
      user_id:         0,
      school_uai_code: 'UNKNOWN0',
      from_date:       (agreement.created_at - 1.day).strftime('%d/%m/%Y')
    )

    agreement.reload
    assert_equal original_email, agreement.school_representative_email
  end

  test 'skips update when date format is invalid' do
    agreement = create(:mono_internship_agreement)
    student   = agreement.internship_application.student
    school    = student.school
    manager   = create(:school_manager, school: school)
    original_email = agreement.school_representative_email

    invoke_task(
      user_id:         manager.id,
      school_uai_code: school.code_uai,
      from_date:       'not-a-date'
    )

    agreement.reload
    assert_equal original_email, agreement.school_representative_email
  end

  test 'skips update when school UAI code is not found' do
    agreement = create(:mono_internship_agreement)
    student   = agreement.internship_application.student
    school    = student.school
    manager   = create(:school_manager, school: school)
    original_email = agreement.school_representative_email

    invoke_task(
      user_id:         manager.id,
      school_uai_code: 'UNKNOWN0',
      from_date:       (agreement.created_at - 1.day).strftime('%d/%m/%Y')
    )

    agreement.reload
    assert_equal original_email, agreement.school_representative_email
  end
end
