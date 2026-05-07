module Services::EmployerActions
  class Resolver
    # TODO maybe remove the action_type parameter and just resolve
    #  all action types for the given user and urgency level
    def self.call(user_id:, urgency_levels:)
      urgency_levels = Array(urgency_levels)
      urgency_levels.each do |urgency_level|
        extra_resolver(user_id:, urgency_level:)
        standard_resolver(user_id:, urgency_level:)
      end
      MailActionItem.where(user_id:)
                    .resolved
                    .delete_all
    end

    # Helpers

    def self.extra_resolver(user_id:, urgency_level:)
      # ------------------------
      # new_internship_application case
      # ------------------------
      # application which aasm_state is not :submitted are to be set as resolved
      actions = MailActionItem.where(
        user_id:,
        urgency_level:,
        action_name: "new_internship_application"
      )
      if actions.present?
        actions.each do |mail_action_item|
          extra_condition = mail_action_item&.internship_application&.aasm_state != "submitted"
          application_resolve(mail_action_item.internship_application, extra_condition)
        end
      end

      # ------------------------
      # canceled_internship_application_by_student case
      # ------------------------
      actions = MailActionItem.where(
        user_id:,
        urgency_level:,
        action_name: "canceled_internship_application_by_student"
      )
      actions.present? && actions.each do |item|
        extra_condition = item&.internship_application&.canceled_by_student_confirmation?
        application_resolve(item.internship_application, extra_condition)
      end

      # =======================================================
      # ------------------- AGREEMENTS ------------------------
      # =======================================================

      # ------------------------
      # agreement_signed_by_all case
      # ------------------------
      agreement_signed_by_all_items = MailActionItem.where(
        user_id:,
        urgency_level:,
        action_name: "agreement_signed_by_all"
      )
      agreement_signed_by_all_items.present? && agreement_signed_by_all_items.each do |item|
        agreement_resolve(item.internship_agreement)
      end
    end

    def self.standard_resolver(user_id:, urgency_level:)
      mail_action_items_base = MailActionItem.where(user_id:)
                                             .where(urgency_level: urgency_level)
      # Only delete stale or over-delivered items, not items just resolved
      mail_action_items_base.where("stale_at < ?", Time.current)
                            .delete_all
      mail_action_items_base.where("deliveries_count >= max_deliveries_count")
                            .delete_all
    end

    def self.application_resolve(application, extra_condition = false)
      if application.nil?
        MailActionItem.where(
          action_type: :pending_internship_application,
        ).each do |item|
          item.update_columns(resolved_at: Time.current)
        end
      elsif extra_condition
        MailActionItem.where(
          action_type: :pending_internship_application,
          internship_application_id: application.id,
        ).each do |item|
          item.update_columns(resolved_at: Time.current)
        end
      end
    end

    def self.agreement_resolve(agreement, extra_condition = false)
      if agreement.nil?
        MailActionItem.where(
          action_type: :pending_internship_agreement,
        ).each do |item|
          item.update_columns(resolved_at: Time.current)
        end
      elsif agreement.discarded? || extra_condition
        MailActionItem.where(
          action_type: :pending_internship_agreement,
          internship_agreement_id: agreement.id
        ).each do |item|
          item.update_columns(resolved_at: Time.current)
        end
      end
    end
  end
end
