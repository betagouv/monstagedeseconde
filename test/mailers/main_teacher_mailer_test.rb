# frozen_string_literal: true

require 'test_helper'

class MainTeacherMailerTest < ActionMailer::TestCase
  include EmailSpamEuristicsAssertions

  test '#internship_application_approved_with_no_agreement_email' do
    school = create(:school, :with_school_manager)
    student = create(:student_with_class_room_3e, school: school)
    class_room = student.class_room
    internship_offer = create(:weekly_internship_offer_2nde)
    internship_application = create(:weekly_internship_application,
                                    :approved,
                                    internship_offer: internship_offer,
                                    user_id: student.id)
    main_teacher = create(:main_teacher, class_room: , school:)
    # internship_application.approve!
    email = MainTeacherMailer.internship_application_approved_with_no_agreement_email(
      internship_application:,
      main_teacher:
    )
    assert_includes 'Un de vos élèves a été accepté à un stage', email.subject
    assert_includes email.to, main_teacher.email
    assert_nil email.cc
    refute_email_spammyness(email)
  end

  test '#internship_application_approved_with_no_agreement_email sent to all main_teachers' do
    school = create(:school, :with_school_manager)
    student = create(:student_with_class_room_3e, school: school)
    class_room = student.class_room
    internship_offer = create(:weekly_internship_offer_2nde)
    internship_application = create(:weekly_internship_application,
                                    :approved,
                                    internship_offer: internship_offer,
                                    user_id: student.id)
    main_teacher   = create(:main_teacher, class_room: , school: )
    main_teacher_2 = create(:main_teacher, class_room: , school: )
    # internship_application.approve!
    email = MainTeacherMailer.internship_application_approved_with_no_agreement_email(
      internship_application: internship_application,
      main_teacher: main_teacher
    )
    assert_includes 'Un de vos élèves a été accepté à un stage', email.subject
    assert_includes email.to, main_teacher.email
    assert_includes email.to, main_teacher_2.email
    assert_nil email.cc
    refute_email_spammyness(email)
  end
end
