require "test_helper"

module Services::StudentActions
  class StudentDigestMailerTest < ActiveSupport::TestCase
    test ".perform_for_high_level calls student_digest_email" do
      student = create(:student)
      actions = {
        "pending_internship_application" => [ MailActionItem.new(action_name: "internship_application_rejected") ]
      }
      delivered_mail = Minitest::Mock.new
      delivered_mail.expect(:deliver_later, true)

      captured_kwargs = nil
      mailer_stub = lambda do |**kwargs|
        captured_kwargs = kwargs
        delivered_mail
      end

      Services::StudentActions::Resolver.stub(:call, nil) do
        Services::StudentActions::StudentDigestMailer.stub(:urgency_levels_sum_up, [ "high" ]) do
          Services::StudentActions::StudentDigestMailer.stub(:find_actions, actions) do
            Services::StudentActions::StudentDigestMailer.stub(:manage_actions_post_delivery, nil) do
              StudentActionsMailer.stub(:student_digest_email, mailer_stub) do
                Services::StudentActions::StudentDigestMailer.perform_for_high_level(user_id: student.id)
              end
            end
          end
        end
      end

      assert_equal student.id, captured_kwargs[:user_id]
      assert_equal actions, captured_kwargs[:actions]
      assert_equal [ "high" ], captured_kwargs[:urgency_levels]
      delivered_mail.verify
    end

    test ".perform_for_high_level does not call employer_digest_email" do
      student = create(:student)
      actions = {
        "pending_internship_application" => [ MailActionItem.new(action_name: "internship_application_rejected") ]
      }
      delivered_mail = Minitest::Mock.new
      delivered_mail.expect(:deliver_later, true)
      student_mailer_called = false

      student_mailer_stub = lambda do |**_kwargs|
        student_mailer_called = true
        delivered_mail
      end

      wrong_mailer_stub = lambda do |**_kwargs|
        raise "employer_digest_email should not be called for student digest"
      end

      Services::StudentActions::Resolver.stub(:call, nil) do
        Services::StudentActions::StudentDigestMailer.stub(:urgency_levels_sum_up, [ "high" ]) do
          Services::StudentActions::StudentDigestMailer.stub(:find_actions, actions) do
            Services::StudentActions::StudentDigestMailer.stub(:manage_actions_post_delivery, nil) do
              EmployerActionsMailer.stub(:employer_digest_email, wrong_mailer_stub) do
                StudentActionsMailer.stub(:student_digest_email, student_mailer_stub) do
                  Services::StudentActions::StudentDigestMailer.perform_for_high_level(user_id: student.id)
                end
              end
            end
          end
        end
      end

      assert student_mailer_called
      delivered_mail.verify
    end

    test "#find_actions filters out empty action groups" do
      item = Struct.new(:id).new(123)

      fake_actions = {
        "pending_internship_application" => [ item ],
        "pending_internship_agreement"   => []
      }

      Services::CommonActions::DigestBuilder.stub(
        :build_digest_by_user_and_urgency_level,
        fake_actions
      ) do
        result = Services::StudentActions::StudentDigestMailer.find_actions(
          user_id: 1,
          urgency_levels: [ "high" ]
        )
        assert_equal [ "pending_internship_application" ], result.keys
      end
    end

    test "#find_actions returns empty hash when digest is empty" do
      Services::CommonActions::DigestBuilder.stub(
        :build_digest_by_user_and_urgency_level,
        {}
      ) do
        assert_equal({},
                     Services::StudentActions::StudentDigestMailer.find_actions(
                       user_id: 1,
                       urgency_levels: [ "high" ]
                     ))
      end
    end
  end
end
