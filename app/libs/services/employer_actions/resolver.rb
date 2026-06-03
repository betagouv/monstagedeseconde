module Services::EmployerActions
  # Resolver clears mail_action_items which are either stale (stale_at in the past)
  # or over-delivered (deliveries_count >= max_deliveries_count)
  class Resolver
    # TODO maybe remove the action_type parameter and just resolve
    # Resolver.call is currently called in two different contexts: internship applications and agreements;
    # the purpose is to resolve pending actions for a given user by checking the state of the related.
    # When resolved pending actions are flagged as resolved by setting resolved_at, and then removed,
    # just before proceeding to email sending.
    def self.call(user_id:, urgency_levels:)
      #  standard and extra aim to set resolved_at for items, which flags them
      #  as resoved and then removed from queue
      urgency_levels = Array(urgency_levels)
      urgency_levels.each do |urgency_level|
        # order matters here as some actions require specific checks before being resolved
        extra_resolver(user_id:, urgency_level:)
        standard_resolver(user_id:, urgency_level:)
      end
      MailActionItem.for_user(user_id)
                    .resolved
                    .delete_all
    end

    # Helpers

    def self.extra_resolver(user_id:, urgency_level:)
      # ------------------------
      # new_internship_application case
      # ------------------------
      # application which aasm_state is not :submitted are to be set as resolved
      actions = MailActionItem.for_user(user_id)
                              .where(urgency_level:)
                              .where(action_name: "new_internship_application")
      if actions.present?
        actions.each do |mail_action_item|
          unless mail_action_item&.internship_application&.submitted?
            application_resolve(mail_action_item.internship_application)
          end
        end
      end

      # ------------------------
      # canceled_internship_application_by_student case
      # ------------------------
      actions = MailActionItem.for_user(user_id)
                              .where(urgency_level:)
                              .where(action_name: "canceled_internship_application_by_student")
      actions.present? && actions.each do |item|
        application = item.internship_application
        not_canceled = !application&.canceled_by_student?
        never_seen_by_employer = !application&.has_ever_been?(%w[read_by_employer])
        if not_canceled || never_seen_by_employer
          application_resolve(application)
        end
      end

      # ------------------------
      # restored_internship_application case
      # ------------------------
      actions = MailActionItem.for_user(user_id)
                              .where(urgency_level:)
                              .where(action_name: "restored_internship_application")
      actions.present? && actions.each do |item|
        application = item.internship_application
        not_restored = application&.aasm_state != "restored"
        never_seen_by_employer = !application&.has_ever_been?(%w[read_by_employer])
        if not_restored || never_seen_by_employer
          application_resolve(application)
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
          application_resolve(item.internship_application)
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
        agreement_resolve(item.internship_agreement) unless do_not_resolve_conditions
      end

      # ------------------------
      # agreement_signed_by_all case
      # ------------------------

      # ------------------------
      # agreement_to_sign case
      # ------------------------
      agreement_to_sign_items = MailActionItem.for_user(user_id)
                                              .where(urgency_level:)
                                              .where(action_name: "agreement_to_sign")
      agreement_to_sign_items.present? && agreement_to_sign_items.each do |item|
        unless item&.internship_agreement&.roles_not_signed_yet&.include?("employer")
          agreement_resolve(item.internship_agreement)
        end
      end
    end

    def self.standard_resolver(user_id:, urgency_level:)
      mail_action_items_base = MailActionItem.for_user(user_id)
                                             .where(urgency_level: urgency_level)
      # Only delete stale or over-delivered items, not items just resolved
      mail_action_items_base.where("stale_at < ?", Time.current)
                            .delete_all
      mail_action_items_base.where("deliveries_count >= max_deliveries_count")
                            .delete_all
    end

    private

    def self.application_resolve(application)
      return unless application.present? && application.persisted?

      MailActionItem.where(
        action_type: :pending_internship_application,
        internship_application_id: application.id,
      ).each do |item|
        item.update_columns(resolved_at: Time.current)
      end
    end

    def self.agreement_resolve(agreement)
      return unless agreement.present? && agreement.persisted?

      MailActionItem.where(
        action_type: :pending_internship_agreement,
        internship_agreement_id: agreement.id
      ).each do |item|
        item.update_columns(resolved_at: Time.current)
      end
    end
  end
end
