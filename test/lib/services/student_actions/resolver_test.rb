require "test_helper"

module Services
  module StudentActions
    class ResolverTest < ActiveSupport::TestCase
      # ---------------------------------------------------------------------------
      # internship_application_rejected
      # ---------------------------------------------------------------------------
      test ".call resolves internship_application_rejected when application is no longer rejected" do
        internship_application = create(:weekly_internship_application, :approved)
        student = internship_application.student

        item = MailActionItem.create!(
          recipient: student,
          action_name: "internship_application_rejected",
          action_type: :pending_internship_application,
          urgency_level: :high,
          stale_at: 5.days.from_now,
          resolved_at: nil,
          deliveries_count: 0,
          max_deliveries_count: 1,
          internship_application: internship_application
        )

        Services::StudentActions::Resolver.call(user_id: student.id, urgency_levels: %w[high])

        assert_raises(ActiveRecord::RecordNotFound) { item.reload }
      end

      test ".call does not resolve internship_application_rejected when application is still rejected" do
        internship_application = create(:weekly_internship_application, :rejected)
        student = internship_application.student

        item = MailActionItem.create!(
          recipient: student,
          action_name: "internship_application_rejected",
          action_type: :pending_internship_application,
          urgency_level: :high,
          stale_at: 5.days.from_now,
          resolved_at: nil,
          deliveries_count: 0,
          max_deliveries_count: 1,
          internship_application: internship_application
        )

        Services::StudentActions::Resolver.call(user_id: student.id, urgency_levels: %w[high])

        assert_nil item.reload.resolved_at
      end

      # ---------------------------------------------------------------------------
      # internship_application_validated_by_employer
      # ---------------------------------------------------------------------------
      test ".call resolves internship_application_validated_by_employer when application is no longer waiting" do
        internship_application = create(:weekly_internship_application, :approved)
        student = internship_application.student

        item = MailActionItem.create!(
          recipient: student,
          action_name: "internship_application_validated_by_employer",
          action_type: :pending_internship_application,
          urgency_level: :high,
          stale_at: 5.days.from_now,
          resolved_at: nil,
          deliveries_count: 0,
          max_deliveries_count: 1,
          internship_application: internship_application
        )

        Services::StudentActions::Resolver.call(user_id: student.id, urgency_levels: %w[high])

        assert_raises(ActiveRecord::RecordNotFound) { item.reload }
      end

      test ".call does not resolve internship_application_validated_by_employer when application still awaits student" do
        internship_application = create(:weekly_internship_application, :validated_by_employer)
        student = internship_application.student

        item = MailActionItem.create!(
          recipient: student,
          action_name: "internship_application_validated_by_employer",
          action_type: :pending_internship_application,
          urgency_level: :high,
          stale_at: 5.days.from_now,
          resolved_at: nil,
          deliveries_count: 0,
          max_deliveries_count: 1,
          internship_application: internship_application
        )

        Services::StudentActions::Resolver.call(user_id: student.id, urgency_levels: %w[high])

        assert_nil item.reload.resolved_at
      end

      # ---------------------------------------------------------------------------
      # agreement_to_sign
      # ---------------------------------------------------------------------------
      test ".call resolves agreement_to_sign when student has signed" do
        internship_agreement = create(:mono_internship_agreement)
        student = internship_agreement.internship_application.student
        create(:signature, :student, internship_agreement: internship_agreement, user_id: student.id)

        item = MailActionItem.create!(
          recipient: student,
          action_name: "agreement_to_sign",
          action_type: :pending_internship_agreement,
          urgency_level: :medium,
          stale_at: 5.days.from_now,
          resolved_at: nil,
          deliveries_count: 0,
          max_deliveries_count: 1,
          internship_agreement: internship_agreement
        )

        Services::StudentActions::Resolver.call(user_id: student.id, urgency_levels: %w[medium])

        assert_raises(ActiveRecord::RecordNotFound) { item.reload }
      end

      test ".call does not resolve agreement_to_sign when student has not signed" do
        internship_agreement = create(:mono_internship_agreement)
        student = internship_agreement.internship_application.student

        item = MailActionItem.create!(
          recipient: student,
          action_name: "agreement_to_sign",
          action_type: :pending_internship_agreement,
          urgency_level: :medium,
          stale_at: 5.days.from_now,
          resolved_at: nil,
          deliveries_count: 0,
          max_deliveries_count: 1,
          internship_agreement: internship_agreement
        )

        Services::StudentActions::Resolver.call(user_id: student.id, urgency_levels: %w[medium])

        assert_nil item.reload.resolved_at
      end

      # ---------------------------------------------------------------------------
      # standard_resolver — stale and over-delivered cleanup
      # ---------------------------------------------------------------------------
      test ".call removes stale and over-delivered student items" do
        internship_application = create(:weekly_internship_application, :rejected)
        student = internship_application.student

        kept = MailActionItem.create!(
          recipient: student,
          action_name: "internship_application_rejected",
          action_type: :pending_internship_application,
          urgency_level: :high,
          stale_at: 5.days.from_now,
          resolved_at: nil,
          deliveries_count: 0,
          max_deliveries_count: 2
        )

        MailActionItem.create!(
          recipient: student,
          action_name: "internship_application_rejected",
          action_type: :pending_internship_application,
          urgency_level: :high,
          stale_at: 1.day.ago,
          resolved_at: nil,
          deliveries_count: 0,
          max_deliveries_count: 1
        )

        MailActionItem.create!(
          recipient: student,
          action_name: "internship_application_rejected",
          action_type: :pending_internship_application,
          urgency_level: :high,
          stale_at: 5.days.from_now,
          resolved_at: nil,
          deliveries_count: 2,
          max_deliveries_count: 1
        )

        Services::StudentActions::Resolver.call(user_id: student.id, urgency_levels: %w[high])

        assert_equal [ kept.id ],
                     MailActionItem.where(recipient: student).pluck(:id)
      end
    end
  end
end
