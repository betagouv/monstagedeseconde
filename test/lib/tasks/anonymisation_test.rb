require 'test_helper'

class AnonymisationTest < ActiveSupport::TestCase
  Monstage::Application.load_tasks

  test 'anonymize internship applications' do
    internship_offer = create(:weekly_internship_offer)
    internship_application = create(:weekly_internship_application)
    student = internship_application.student
    student_email = student.email
    school = internship_application.student.school
    class_room = create(:class_room, school:, name: 'Victor Hugo')
    internship_agreement = create(:internship_agreement)
    student.update(class_room:)
    student_identity = create(:identity_student_with_class_room_3e)
    employer = internship_offer.employer

    Rake::Task['anonymisation:all_ms2gt'].invoke

    # student anonymized
    student.reload
    assert_equal student.class_room_id, nil
    assert_equal student.school_id, school.id
    assert_equal student.first_name, 'NA'
    assert_equal student.last_name, 'NA'
    refute_equal student.email, student_email

    # student identity anonymized
    identity_first_name = student_identity.first_name
    identity_last_name = student_identity.last_name
    student_identity.reload
    refute_equal student_identity.first_name, identity_first_name
    refute_equal student_identity.last_name, identity_last_name

    # employer non anonymized
    employer.reload
    refute_equal employer.name, 'NA'

    # internship applications anonymized
    internship_application.reload
    assert_equal internship_application.student_address, 'NA'
    assert_equal internship_application.student_phone, '+330600110011'
    refute_equal internship_application.student_email, student_email
    assert_equal internship_application.student_legal_representative_full_name, 'NA'
    assert_equal internship_application.student_legal_representative_phone, '+330600110011'
    assert_equal internship_application.student_legal_representative_email, 'NA'

    # classes anonymized
    class_room.reload
    assert_equal class_room.name, 'NA'
    assert_equal class_room.school_id, nil

    # internship agreements anonymized
    internship_agreement.reload
    assert_equal internship_agreement.student_address, 'NA'
    assert_equal internship_agreement.student_phone, 'NA'
    assert_equal internship_agreement.organisation_representative_full_name, 'NA'
    assert_equal internship_agreement.school_representative_full_name, 'NA'
    assert_equal internship_agreement.student_full_name, 'NA'
    assert_equal internship_agreement.student_class_room, 'NA'
    assert_equal internship_agreement.student_school, 'NA'
    assert_equal internship_agreement.tutor_full_name, 'NA'
    assert_equal internship_agreement.siret, 'NA'
    assert_equal internship_agreement.tutor_role, 'NA'
    assert_equal internship_agreement.tutor_email, 'NA'
    assert_equal internship_agreement.organisation_representative_role, 'NA'
    assert_equal internship_agreement.student_address, 'NA'
    assert_equal internship_agreement.student_phone, 'NA'
    assert_equal internship_agreement.school_representative_phone, 'NA'
    assert_equal internship_agreement.student_refering_teacher_phone, 'NA'
    assert_equal internship_agreement.student_legal_representative_email, 'NA'
    assert_equal internship_agreement.student_refering_teacher_email, 'NA'
    assert_equal internship_agreement.student_legal_representative_full_name, 'NA'
    assert_equal internship_agreement.student_refering_teacher_full_name, 'NA'
    assert_equal internship_agreement.student_legal_representative_2_full_name, 'NA'
    assert_equal internship_agreement.student_legal_representative_2_email, 'NA'
    assert_equal internship_agreement.student_legal_representative_2_phone, 'NA'
    assert_equal internship_agreement.school_representative_role, 'NA'
    assert_equal internship_agreement.school_representative_email, 'NA'
    assert_equal internship_agreement.student_legal_representative_phone, 'NA'
  end
end
