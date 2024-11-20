# frozen_string_literal: true

require 'test_helper'

class InternshipApplicationTest < ActiveSupport::TestCase
  include ThirdPartyTestHelpers
  include TeamAndAreasHelper

  test 'factory' do
    assert build(:weekly_internship_application).valid?
  end
  test 'scope remindable' do
    create(:weekly_internship_application, :submitted,
           submitted_at: 5.days.ago,
           pending_reminder_sent_at: 5.days.ago)
    create(:weekly_internship_application, :submitted,
           submitted_at: 10.days.ago,
           pending_reminder_sent_at: 10.days.ago) # +1
    create(:weekly_internship_application, :submitted,
           submitted_at: 18.days.ago,
           pending_reminder_sent_at: 18.days.ago)
    create(:weekly_internship_application, :submitted,
           submitted_at: 3.days.ago,
           pending_reminder_sent_at: nil)
    create(:weekly_internship_application, :submitted,
           submitted_at: 8.days.ago,
           pending_reminder_sent_at: 2.days.ago)
    create(:weekly_internship_application, :submitted,
           submitted_at: 8.days.ago,
           pending_reminder_sent_at: nil) # +1
    create(:weekly_internship_application, submitted_at: 15.days.ago,
                                           pending_reminder_sent_at: nil) # +1
    create(:weekly_internship_application, :approved,
           approved_at: 10.days.ago,
           pending_reminder_sent_at: 10.days.ago)
    assert_equal 3, InternshipApplication.remindable.count
  end

  test 'creating a new internship application sets submitted_at and sends email to employer' do
    freeze_time do
      assert_changes -> { InternshipApplication.count }, from: 0, to: 1 do
        mock_mail = Minitest::Mock.new
        mock_mail.expect(:deliver_later, true, [], wait: 1.second)

        EmployerMailer.stub :internship_application_submitted_email, mock_mail do
          StudentMailer.stub :internship_application_submitted_email, mock_mail do
            internship_application = create(:weekly_internship_application)
          end
        end

        assert_equal Time.now.utc, InternshipApplication.last.submitted_at
        mock_mail.verify
      end
    end
  end

  test 'transition from submited to validated_by_employer updates its flag' do
    internship_application = create(:weekly_internship_application, :submitted)

    freeze_time do
      assert_changes -> { internship_application.reload.validated_by_employer_at },
                     from: nil,
                     to: Time.now.utc do
        internship_application.stub :after_employer_validation_notifications, nil do
          internship_application.employer_validate!
        end
      end
    end
  end

  test 'transition from submited to validated_by_employer sends email to main_teacher and student' do
    internship_application = create(:weekly_internship_application, :submitted)
    create(
      :main_teacher,
      class_room: internship_application.student.class_room,
      school: internship_application.student.school
    )
    mock_mail_to_main_teacher = Minitest::Mock.new
    mock_mail_to_main_teacher.expect(:deliver_later, true, [], wait: 1.second)
    mock_mail_to_student = Minitest::Mock.new
    mock_mail_to_student.expect(:deliver_later, true, [], wait: 1.second)

    MainTeacherMailer.stub :internship_application_validated_by_employer_email, mock_mail_to_main_teacher do
      StudentMailer.stub :internship_application_validated_by_employer_email, mock_mail_to_student do
        internship_application.employer_validate!
      end
      mock_mail_to_student.verify
    end
    mock_mail_to_main_teacher.verify
  end

  test 'transition from validated_by_employer to approved updates its flag' do
    internship_application = create(:weekly_internship_application, :validated_by_employer)

    freeze_time do
      assert_changes -> { internship_application.reload.approved_at },
                     from: nil,
                     to: Time.now.utc do
        internship_application.stub :student_approval_notifications, nil do
          internship_application.approve!
        end
      end
    end
  end

  test 'transition from validated_by_employer to approved send approved email to student' do
    internship_application = create(:weekly_internship_application, :validated_by_employer)
    create(:main_teacher,
           class_room: internship_application.student.class_room,
           school: internship_application.student.school)

    internship_application.stub :create_agreement, nil do
      mock_mail_to_main_teacher = Minitest::Mock.new
      mock_mail_to_main_teacher.expect(:deliver_later, true, [], wait: 1.second)

      MainTeacherMailer.stub :internship_application_approved_with_agreement_email, mock_mail_to_main_teacher do
        internship_application.approve!
      end
      mock_mail_to_main_teacher.verify
    end
  end

  # test 'transition from validated_by_employer to approved creates the internship_agreement' do
  #   internship_application = create(:weekly_internship_application, :validated_by_employer)
  #   create(:main_teacher,
  #          class_room: internship_application.student.class_room,
  #          school: internship_application.student.school
  #   )

  #   internship_application.stub :create_agreement, nil do
  #     mock_mail_to_main_teacher = Minitest::Mock.new
  #     mock_mail_to_main_teacher.expect(:deliver_later, true, [] , wait: 1.second)

  #     MainTeacherMailer.stub :internship_application_approved_with_agreement_email, mock_mail_to_main_teacher do
  #       internship_application.approve!
  #     end
  #     mock_mail_to_main_teacher.verify
  #   end
  # end

  test 'transition from submited to approved does not send approved email to student w/o email' do
    student = create(:student, phone: '+330611223944', email: nil)
    internship_application = create(:weekly_internship_application, :submitted, student:)

    freeze_time do
      sms_bitly_stub do
        assert_changes -> { internship_application.reload.approved_at },
                       from: nil,
                       to: Time.now.utc do
          mock_mail_to_student = Minitest::Mock.new
          mock_mail_to_student.expect(:deliver_later, true, [{ wait: 1.second }])
          StudentMailer.stub :internship_application_approved_email, mock_mail_to_student do
            internship_application.save
            internship_application.validated_by_employer!
            internship_application.approve!
          end
          assert_raises(MockExpectationError) { mock_mail_to_student.verify }
        end
      end
    end
  end

  test 'transition from submited to validated_by_employer sends no email when main_teacher misses' do
    school = create(:school)
    class_room = create(:class_room, school:)
    student = build(:student, class_room:)
    create(:school_manager, school:)

    internship_application = create(:weekly_internship_application, :submitted, student:)

    mock_mail_to_main_teacher = Minitest::Mock.new
    mock_mail_to_main_teacher.expect(:deliver_later, true)

    InternshipApplication.stub_any_instance(:after_employer_validation_notifications, nil) do
      MainTeacherMailer.stub(:internship_application_validated_by_employer_email,
                             mock_mail_to_main_teacher) do
        internship_application.save
        internship_application.employer_validate!
      end
      assert_raises(MockExpectationError) { mock_mail_to_main_teacher.verify }
    end
  end

  test 'transition from validated_by_employer to approved sends no email when main_teacher misses' do
    school = create(:school)
    class_room = create(:class_room, school:)
    student = build(:student, class_room:)
    create(:school_manager, school:)

    internship_application = create(:weekly_internship_application, :validated_by_employer, student:)

    mock_mail_to_main_teacher = Minitest::Mock.new
    mock_mail_to_main_teacher.expect(:deliver_later, true)

    InternshipApplication.stub_any_instance(:student_approval_notifications, nil) do
      InternshipApplication.stub_any_instance(:create_agreement, nil) do
        MainTeacherMailer.stub(:internship_application_approved_with_agreement_email,
                               mock_mail_to_main_teacher) do
          internship_application.save
          internship_application.approve!
        end
        assert_raises(MockExpectationError) { mock_mail_to_main_teacher.verify }
      end
    end
  end

  test 'transition from validated_by_employer to approved sends an email to employer when agreement is possible' do
    school = create(:school)
    class_room = create(:class_room, school:)
    student = build(:student, class_room:)
    create(:school_manager, school:)

    internship_application = create(:weekly_internship_application, :validated_by_employer, student:)

    mock_mail_to_employer = Minitest::Mock.new
    mock_mail_to_employer.expect(:deliver_later, true)

    EmployerMailer.stub(:internship_application_approved_with_agreement_email,
                        mock_mail_to_employer) do
      internship_application.approve!
    end
    mock_mail_to_employer.verify
  end

  test 'transition from submited to approved sends an email to school_manager when no agreement is possible' do
    # TO BE CONFIRMED there's no case where agreement is not possible anymore

    # school = create(:school)
    # class_room = create(:class_room, school: school)
    # student = build(:student, class_room: class_room)
    # create(:school_manager, school: school)

    # internship_application = create(:weekly_internship_application, :submitted, student: student)

    # mock_mail_to_school_manager = Minitest::Mock.new
    # mock_mail_to_school_manager.expect(:deliver_later, true)

    # InternshipApplication.stub_any_instance(:accepted_student_notify, nil) do
    #   SchoolManagerMailer.stub(:internship_application_approved_with_no_agreement_email,
    #                             mock_mail_to_school_manager) do
    #     internship_application.save
    #     internship_application.approve!
    #   end
    #   mock_mail_to_school_manager.verify
    # end
  end

  test 'transition from submited to approved sends an email to main_teacher when no agreement is possible' do
    # TO BE CONFIRMED there's no case where agreement is not possible anymore

    # school = create(:school)
    # class_room = create(:class_room, school: school)
    # student = build(:student, class_room: class_room)
    # create(:school_manager, school: school)
    # create(:main_teacher, class_room: class_room, school: school)

    # internship_application = create(:weekly_internship_application, :submitted, student: student)

    # mock_mail_to_main_teacher = Minitest::Mock.new
    # mock_mail_to_main_teacher.expect(:deliver_later, true)

    # InternshipApplication.stub_any_instance(:accepted_student_notify, nil) do
    #   MainTeacherMailer.stub(:internship_application_approved_with_no_agreement_email,
    #                             mock_mail_to_main_teacher) do
    #     internship_application.save
    #     internship_application.approve!
    #   end
    #   mock_mail_to_main_teacher.verify
    # end
  end

  test 'transition from submited to approved create internship_agreement for student' do
    internship_offer = create(:weekly_internship_offer_2nde)
    school = create(:school, :with_school_manager)
    class_room = create(:class_room, school:)
    student = create(:student, class_room:)
    internship_application = create(:weekly_internship_application, :validated_by_employer, student:)

    assert_changes -> { InternshipAgreement.count },
                   'Expected to have created agreement',
                   from: 0,
                   to: 1 do
      internship_application.approve!
    end
  end

  test 'transition from submited to rejected send rejected email to student' do
    internship_application = create(:weekly_internship_application, :submitted)
    freeze_time do
      assert_changes -> { internship_application.reload.rejected_at },
                     from: nil,
                     to: Time.now.utc do
        mock_mail = Minitest::Mock.new
        mock_mail.expect(:deliver_later, true, [], wait: 1.second)
        StudentMailer.stub :internship_application_rejected_email, mock_mail do
          internship_application.reject!
        end
        mock_mail.verify
      end
    end
  end

  test 'transition from rejected to employer_validate sends approved email' do
    internship_application = create(:weekly_internship_application, :rejected)
    freeze_time do
      assert_changes -> { internship_application.reload.validated_by_employer_at },
                     from: nil,
                     to: Time.now.utc do
        mock_mail = Minitest::Mock.new
        mock_mail.expect(:deliver_later, true, [], wait: 1.second)
        StudentMailer.stub :internship_application_validated_by_employer_email, mock_mail do
          internship_application.employer_validate!
        end
        mock_mail.verify
      end
    end
  end

  test 'transition from rejected to validated_by_employer does not send email to student w/o email' do
    student = create(:student, phone: '+330611223944', email: nil)
    internship_application = create(:weekly_internship_application, :rejected, student:)
    sms_bitly_stub do
      freeze_time do
        assert_changes -> { internship_application.reload.validated_by_employer_at },
                       from: nil,
                       to: Time.now.utc do
          mock_mail = Minitest::Mock.new
          mock_mail.expect(:deliver_later, true, [{ wait: 1.second }])
          StudentMailer.stub :internship_application_approved_email, mock_mail do
            internship_application.employer_validate!
          end
          assert_raises(MockExpectationError) { mock_mail.verify }
        end
      end
    end
  end

  test 'transition via cancel_by_employer! changes ' \
       'aasm_state from approved to rejected' do
    internship_application = create(:weekly_internship_application, :approved)
    assert_changes -> { internship_application.reload.aasm_state },
                   from: 'approved',
                   to: 'canceled_by_employer' do
      freeze_time do
        assert_changes -> { internship_application.reload.canceled_at },
                       from: nil,
                       to: Time.now.utc do
          mock_mail = Minitest::Mock.new
          mock_mail.expect(:deliver_later, true, [], wait: 1.second)
          StudentMailer.stub :internship_application_canceled_by_employer_email,
                             mock_mail do
            internship_application.cancel_by_employer!
          end
          mock_mail.verify
        end
      end
    end
  end

  test 'transition via expire! changes aasm_state from submitted to expired' do
    internship_application = create(:weekly_internship_application, :submitted)
    assert_changes -> { internship_application.reload.aasm_state },
                   from: 'submitted',
                   to: 'expired' do
      freeze_time do
        assert_changes -> { internship_application.reload.expired_at },
                       from: nil,
                       to: Time.now.utc do
          internship_application.expire!
        end
      end
    end
  end

  test 'RGPD' do
    internship_application = create(:weekly_internship_application, motivation: 'amazing')

    internship_application.anonymize

    assert_not_equal 'amazing', internship_application.motivation
  end

  test '#after_employer_validation_notifications when student registered by phone' do
    student = create(:student, :registered_with_phone)
    internship_application = create(:weekly_internship_application, student:)
    assert internship_application.after_employer_validation_notifications.is_a?(SendSmsStudentValidatedApplicationJob)
  end

  test '#after_employer_validation_notifications when student registered by email' do
    student = create(:student)
    internship_application = create(:weekly_internship_application, student:)

    mock_mail = Minitest::Mock.new
    mock_mail.expect(:deliver_later, true, [], wait: 1.second)

    StudentMailer.stub :internship_application_validated_by_employer_email, mock_mail do
      internship_application.after_employer_validation_notifications
    end
    mock_mail.verify
  end

  test '#should_notify_employer_like?' do
    employer_1 = create(:employer)
    employer_2 = create(:employer)
    offer = create_internship_offer_visible_by_two(employer_1, employer_2)
    internship_application = create(:weekly_internship_application, internship_offer: offer)

    assert_equal 2, internship_application.filter_notified_emails.count

    # update : employer_1 no longer receives notifications
    area_notification = employer_1.fetch_current_area_notification
    area_notification.update_column(:notify, false)
    assert_equal [employer_2.email], internship_application.filter_notified_emails
  end

  test '::PENDING_STATES' do
    assert_equal %w[submitted read_by_employer transfered validated_by_employer],
                 InternshipApplication::PENDING_STATES
  end

  test '.order_by_aasm_state_for_student' do
    skip 'This test is flaky, it fails on CI' if ENV['CI'] == true
    internship_application_1 = nil
    internship_application_2 = nil
    internship_application_3 = nil
    internship_application_4 = nil
    internship_application_5 = nil
    travel_to Time.zone.local(2024, 1, 1, 12, 0, 0) do
      internship_application_1 = create(:weekly_internship_application, :submitted) # n°3 in the list by created_at
    end
    travel_to Time.zone.local(2024, 1, 1, 13, 0, 0) do
      internship_application_2 = create(:weekly_internship_application, :validated_by_employer) # n°1 in the list by status
    end
    travel_to Time.zone.local(2024, 1, 1, 14, 0, 0) do
      internship_application_3 = create(:weekly_internship_application) # n°4 in the list by created_at
    end
    travel_to Time.zone.local(2024, 1, 1, 15, 0, 0) do
      internship_application_4 = create(:weekly_internship_application, :read_by_employer) # n°5 in the list by created_at
    end
    travel_to Time.zone.local(2024, 1, 1, 16, 0, 0) do
      internship_application_5 = create(:weekly_internship_application, :validated_by_employer) # n°2 in the list by status
    end
    sleep 1

    assert_equal internship_application_2.id, InternshipApplication.order_by_aasm_state_for_student.first.id
    assert_equal internship_application_5.id, InternshipApplication.order_by_aasm_state_for_student.second.id
    assert_equal internship_application_1.id, InternshipApplication.order_by_aasm_state_for_student.third.id
    assert_equal internship_application_3.id, InternshipApplication.order_by_aasm_state_for_student.fourth.id
    assert_equal internship_application_4.id, InternshipApplication.order_by_aasm_state_for_student.fifth.id
  end
end
