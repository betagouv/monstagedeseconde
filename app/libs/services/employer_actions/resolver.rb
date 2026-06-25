module Services::EmployerActions
  # Resolver clears mail_action_items which are either stale (stale_at in the past)
  # or over-delivered (deliveries_count >= max_deliveries_count)
  class Resolver < ::Services::CommonActions::BaseResolver
    def self.extra_resolver(user_id:, urgency_level:)
      # ------------------------
      # canceled_internship_application_by_student case
      # ------------------------
      # resolved (i.e. not notified) unless the application is actually canceled by
      # the student AND the employer had read it before the cancellation.
      # Runs before new_internship_application below so that its resolution of the
      # whole application doesn't wipe this item out as collateral damage.
      actions = MailActionItem.for_user(user_id)
                              .where(urgency_level:)
                              .where(action_name: "canceled_internship_application_by_student")
      actions.present? && actions.each do |item|
        application = item.internship_application
        not_canceled = !application&.canceled_by_student?
        never_seen_by_employer = !application&.has_ever_been?(%w[read_by_employer])
        item.update_columns(resolved_at: Time.current) if not_canceled || never_seen_by_employer
      end

      # ------------------------
      # restored_internship_application case
      # ------------------------
      # resolved (i.e. not notified) unless the application is actually restored AND
      # the employer had read it at some point in its history.
      # Runs before new_internship_application below so that its resolution of the
      # whole application doesn't wipe this item out as collateral damage.
      actions = MailActionItem.for_user(user_id)
                              .where(urgency_level:)
                              .where(action_name: "restored_internship_application")
      actions.present? && actions.each do |item|
        application = item.internship_application
        not_restored = application&.aasm_state != "restored"
        never_seen_by_employer = !application&.has_ever_been?(%w[read_by_employer])
        item.update_columns(resolved_at: Time.current) if not_restored || never_seen_by_employer
      end

      # ------------------------
      # new_internship_application case
      # ------------------------
      # application which aasm_state is not :submitted are to be set as resolved
      # Exception: if the application is restored but never seen by employer,
      # keep new_internship_application so the application still appears in the digest (D2).
      actions = MailActionItem.for_user(user_id)
                              .where(urgency_level:)
                              .where(action_name: "new_internship_application")
      if actions.present?
        actions.each do |mail_action_item|
          application = mail_action_item&.internship_application
          next if application&.restored? && !application&.has_ever_been?(%w[read_by_employer])
          application_resolve(application, user_id:) unless application&.submitted?
        end
      end

      # ------------------------
      # cancel_by_student_confirmation case
      # ------------------------
      actions = MailActionItem.for_user(user_id).where(
        urgency_level:,
        action_name: "cancel_by_student_confirmation"
      )
      actions.present? && actions.each do |item|
        unless item&.internship_application&.canceled_by_student_confirmation?
          application_resolve(item.internship_application, user_id:)
        end
      end

      # =======================================================
      # ------------------- AGREEMENTS ------------------------
      # =======================================================

      # ------------------------
      # new_agreement_to_fill_in case
      # ------------------------
      new_agreement_to_fill_in_items = MailActionItem.for_user(user_id)
                                                     .where(urgency_level:)
                                                     .where(action_name: "new_agreement_to_fill_in")
      new_agreement_to_fill_in_items.present? && new_agreement_to_fill_in_items.each do |item|
        do_not_resolve_conditions = item&.internship_agreement&.kept? &&
                                    item.internship_agreement&.draft?
        agreement_resolve(item.internship_agreement, user_id:) unless do_not_resolve_conditions
      end

      # ------------------------
      # agreement_signed_by_all case
      # ------------------------
      # Resolved (i.e. not notified) if the employer has signed: they already know.
      agreement_signed_by_all_items = MailActionItem.for_user(user_id)
                                                    .where(urgency_level:)
                                                    .where(action_name: "agreement_signed_by_all")
      agreement_signed_by_all_items.present? && agreement_signed_by_all_items.each do |item|
        if item&.internship_agreement&.signed_by_employer?
          item.update_columns(resolved_at: Time.current)
          agreement_resolve(item.internship_agreement, user_id:)
        end
      end

      # ------------------------
      # agreement_signed_by_another case
      # ------------------------
      # Resolved once the employer has signed (they no longer need the nudge).
      agreement_signed_by_another_items = MailActionItem.for_user(user_id)
                                                        .where(urgency_level:)
                                                        .where(action_name: "agreement_signed_by_another")
      agreement_signed_by_another_items.present? && agreement_signed_by_another_items.each do |item|
        if item&.internship_agreement&.signed_by_employer?
          item.update_columns(resolved_at: Time.current)
        end
      end

      # ------------------------
      # agreement_to_sign case
      # ------------------------
      agreement_to_sign_items = MailActionItem.for_user(user_id)
                                              .where(urgency_level:)
                                              .where(action_name: "agreement_to_sign")
      agreement_to_sign_items.present? && agreement_to_sign_items.each do |item|
        unless item&.internship_agreement&.roles_not_signed_yet&.include?("employer")
          item.update_columns(resolved_at: Time.current)
        end
      end
    end

    private

    # action_names with their own dedicated resolution rules above:
    # they must not be wiped out as collateral damage here.
    SELF_RESOLVING_ACTION_NAMES = %w[
      canceled_internship_application_by_student
      cancel_by_student_confirmation
      restored_internship_application
    ].freeze

    SELF_RESOLVING_AGREEMENT_ACTION_NAMES = %w[
      agreement_to_sign
      agreement_signed_by_another
    ].freeze

    def self.application_resolve(application, user_id:)
      return unless application.present? && application.persisted?

      MailActionItem.for_user(user_id)
                    .where(
                      action_type: :pending_internship_application,
                      internship_application_id: application.id,
                    ).where.not(action_name: SELF_RESOLVING_ACTION_NAMES).each do |item|
        item.update_columns(resolved_at: Time.current)
      end
    end

    def self.agreement_resolve(agreement, user_id:)
      return unless agreement.present? && agreement.persisted?

      MailActionItem.for_user(user_id)
                    .where(
                      action_type: :pending_internship_agreement,
                      internship_agreement_id: agreement.id
                    ).where.not(action_name: SELF_RESOLVING_AGREEMENT_ACTION_NAMES).each do |item|
        item.update_columns(resolved_at: Time.current)
      end
    end
  end
end
