require "test_helper"

module Services::SchoolManagementActions
  class SchoolManagementDigestMailerTest < ActiveSupport::TestCase
    test ".perform_for_medium_level calls school_management_digest_email" do
      school_manager = create(:school_manager)
      actions = {
        "pending_internship_agreement" => [ MailActionItem.new(action_name: "agreement_signed_by_all") ]
      }
      delivered_mail = Minitest::Mock.new
      delivered_mail.expect(:deliver_later, true)

      captured_kwargs = nil
      mailer_stub = lambda do |**kwargs|
        captured_kwargs = kwargs
        delivered_mail
      end

      Services::SchoolManagementActions::Resolver.stub(:call, nil) do
        Services::SchoolManagementActions::SchoolManagementDigestMailer.stub(:urgency_levels_sum_up, [ "medium" ]) do
          Services::SchoolManagementActions::SchoolManagementDigestMailer.stub(:find_actions, actions) do
            Services::SchoolManagementActions::SchoolManagementDigestMailer.stub(:manage_actions_post_delivery, nil) do
              SchoolManagementActionsMailer.stub(:school_management_digest_email, mailer_stub) do
                Services::SchoolManagementActions::SchoolManagementDigestMailer.perform_for_medium_level(user_id: school_manager.id)
              end
            end
          end
        end
      end

      assert_equal school_manager.id, captured_kwargs[:user_id]
      assert_equal actions, captured_kwargs[:actions]
      assert_equal [ "medium" ], captured_kwargs[:urgency_levels]
      delivered_mail.verify
    end

    test ".perform_for_medium_level does not call employer_digest_email" do
      school_manager = create(:school_manager)
      actions = {
        "pending_internship_agreement" => [ MailActionItem.new(action_name: "agreement_signed_by_all") ]
      }
      delivered_mail = Minitest::Mock.new
      delivered_mail.expect(:deliver_later, true)
      school_mailer_called = false

      school_mailer_stub = lambda do |**_kwargs|
        school_mailer_called = true
        delivered_mail
      end

      legacy_mailer_stub = lambda do |**_kwargs|
        raise "employer_digest_email should not be called for school management digest"
      end

      Services::SchoolManagementActions::Resolver.stub(:call, nil) do
        Services::SchoolManagementActions::SchoolManagementDigestMailer.stub(:urgency_levels_sum_up, [ "medium" ]) do
          Services::SchoolManagementActions::SchoolManagementDigestMailer.stub(:find_actions, actions) do
            Services::SchoolManagementActions::SchoolManagementDigestMailer.stub(:manage_actions_post_delivery, nil) do
              SchoolManagementActionsMailer.stub(:employer_digest_email, legacy_mailer_stub) do
                SchoolManagementActionsMailer.stub(:school_management_digest_email, school_mailer_stub) do
                  Services::SchoolManagementActions::SchoolManagementDigestMailer.perform_for_medium_level(user_id: school_manager.id)
                end
              end
            end
          end
        end
      end

      assert school_mailer_called
      delivered_mail.verify
    end

    #   test ".purge_actions_for_user_and_level removes stale resolved and maxed" do
    #     employer = create(:employer)

    #     kept = MailActionItem.create!(
    #       recipient: employer,
    #       action_name: "internship_offer_removed",
    #       action_type: :pending_internship_offer,
    #       urgency_level: :medium,
    #       stale_at: 2.days.from_now,
    #       resolved_at: nil,
    #       deliveries_count: 0,
    #       max_deliveries_count: 1
    #     )

    #     MailActionItem.create!(
    #       recipient: employer,
    #       action_name: "internship_offer_removed",
    #       action_type: :pending_internship_offer,
    #       urgency_level: :medium,
    #       stale_at: 2.days.from_now,
    #       resolved_at: Time.current,
    #       deliveries_count: 0,
    #       max_deliveries_count: 1
    #     )

    #     MailActionItem.create!(
    #       recipient: employer,
    #       action_name: "internship_offer_removed",
    #       action_type: :pending_internship_offer,
    #       urgency_level: :medium,
    #       stale_at: 1.day.ago,
    #       resolved_at: nil,
    #       deliveries_count: 0,
    #       max_deliveries_count: 1
    #     )

    #     MailActionItem.create!(
    #       recipient: employer,
    #       action_name: "internship_offer_removed",
    #       action_type: :pending_internship_offer,
    #       urgency_level: :medium,
    #       stale_at: 2.days.from_now,
    #       resolved_at: nil,
    #       deliveries_count: 2,
    #       max_deliveries_count: 1
    #     )

    #     Services::EmployerActions::Resolver.call(
    #       user_id: employer.id,
    #       urgency_levels: %w[low medium]
    #     )

    #     assert_equal [ kept.id ],
    #                  MailActionItem.where(recipient: employer).pluck(:id)
    #   end

    #   test "#find_actions filters out empty action groups" do
    #     item = Struct.new(:id).new(123)

    #     fake_actions = {
    #       "pending_internship_application" => [ item ],
    #       "agreement_to_sign" => []
    #     }

    #     Services::EmployerActions::DigestBuilder.stub(
    #       :build_digest_by_user_and_urgency_level,
    #       fake_actions
    #     ) do
    #       result = Services::EmployerActions::EmployerDigestMailer.find_actions(
    #         user_id: 1,
    #         urgency_levels: [ "medium" ]
    #       )
    #       assert_equal [ "pending_internship_application" ], result.keys
    #     end
    #   end

    #   test "#find_actions returns empty hash when digest is empty" do
    #     Services::EmployerActions::DigestBuilder.stub(
    #       :build_digest_by_user_and_urgency_level,
    #       {}
    #     ) do
    #       assert_equal({},
    #                    Services::EmployerActions::EmployerDigestMailer.find_actions(
    #                      user_id: 1,
    #                      urgency_levels: [ "medium" ]
    #                    ))
    #     end
    #   end

    #   test ".perform_for_medium_level delivers for canceled_internship_application_by_student" do
    #     internship_application = create(:weekly_internship_application)
    #     employer = internship_application.internship_offer.employer
    #     internship_application.update_columns(aasm_state: "canceled_by_student")
    #     MailActionItem.delete_all

    #     item = MailActionItem.create!(
    #       recipient: employer,
    #       action_name: "canceled_internship_application_by_student",
    #       action_type: :pending_internship_application,
    #       internship_application:,
    #       urgency_level: :medium,
    #       stale_at: 30.days.from_now,
    #       resolved_at: nil,
    #       deliveries_count: 0,
    #       max_deliveries_count: 1
    #     )

    #     Services::EmployerActions::EmployerDigestMailer.perform_for_medium_level(user_id: employer.id)

    #     assert_equal [ item.id ],
    #                  MailActionItem.where(recipient: employer, deliveries_count: 1).pluck(:id)
    #   end

    #   test ".perform_for_medium_level delivers for restored_internship_application" do
    #     internship_application = create(:weekly_internship_application, :restored)
    #     employer = internship_application.internship_offer.employer
    #     MailActionItem.delete_all

    #     item = MailActionItem.create!(
    #       recipient: employer,
    #       action_name: "restored_internship_application",
    #       action_type: :pending_internship_application,
    #       internship_application:,
    #       urgency_level: :medium,
    #       stale_at: 30.days.from_now,
    #       resolved_at: nil,
    #       deliveries_count: 0,
    #       max_deliveries_count: 1
    #     )

    #     Services::EmployerActions::EmployerDigestMailer.perform_for_medium_level(user_id: employer.id)

    #     assert_equal [ item.id ],
    #                  MailActionItem.where(recipient: employer, deliveries_count: 1).pluck(:id)
    #   end

    #   test ".perform_for_high_level delivers for cancel_by_student_confirmation" do
    #     internship_application = create(:weekly_internship_application, :submitted)
    #     employer = internship_application.internship_offer.employer
    #     internship_application.update_columns(aasm_state: "canceled_by_student_confirmation")
    #     MailActionItem.delete_all

    #     item = MailActionItem.create!(
    #       recipient: employer,
    #       action_name: "cancel_by_student_confirmation",
    #       action_type: :pending_internship_application,
    #       internship_application:,
    #       urgency_level: :high,
    #       stale_at: 30.days.from_now,
    #       resolved_at: nil,
    #       deliveries_count: 0,
    #       max_deliveries_count: 1
    #     )

    #     Services::EmployerActions::EmployerDigestMailer.perform_for_high_level(user_id: employer.id)

    #     assert_equal [ item.id ],
    #                  MailActionItem.where(recipient: employer, deliveries_count: 1).pluck(:id)
    #   end

    #   test "#perform_for_low_level performs expected operations" do
    #     internship_application = create(:weekly_internship_application)
    #     employer = internship_application.internship_offer.employer
    #     MailActionItem.delete_all

    #     valid_medium = MailActionItem.create!(
    #       recipient: employer,
    #       action_name: "new_internship_application",
    #       action_type: :pending_internship_application,
    #       internship_application:,
    #       urgency_level: :medium,
    #       stale_at: 4.days.from_now,
    #       resolved_at: nil,
    #       deliveries_count: 0,
    #       max_deliveries_count: 1
    #     )

    #     Services::EmployerActions::EmployerDigestMailer.perform_for_medium_level(user_id: employer.id)

    #     assert_equal [ valid_medium.id ],
    #                  MailActionItem.where(recipient: employer, deliveries_count: 1).pluck(:id)
    #   end
    # end
  end
end
