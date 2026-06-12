module Services::SchoolManagementActions
  class Resolver
    # TODO maybe remove the action_type parameter and just resolve
    #  all action types for the given user and urgency level
    def self.call(user_id:, urgency_levels:)
      urgency_levels = Array(urgency_levels)
      urgency_levels.each do |urgency_level|
        extra_resolver(user_id:, urgency_level:)
        standard_resolver(user_id:, urgency_level:)
      end
      MailActionItem.for_user(user_id)
                    .resolved
                    .delete_all
    end

    # Helpers

    def self.extra_resolver(user_id:, urgency_level:)
      # School managers only manage internship agreements, not applications.
      # =======================================================
      # ------------------- AGREEMENTS ------------------------
      # =======================================================

      # ------------------------
      # internship_agreement_completed_by_employer case
      # ------------------------
      # "Conventions à compléter" is stale once the agreement has moved past
      # completed_by_employer (e.g. validated, ready to be signed).
      completed_by_employer_items = MailActionItem.for_user(user_id)
                                                   .where(urgency_level:)
                                                   .where(action_name: "internship_agreement_completed_by_employer")
      completed_by_employer_items.present? && completed_by_employer_items.each do |item|
        unless item&.internship_agreement&.completed_by_employer?
          item.update_columns(resolved_at: Time.current)
        end
      end

      # ------------------------
      # new_agreement_to_fill_in case
      # -------------------------------------------------------
      new_agreement_to_fill_in_items = MailActionItem.for_user(user_id)
                                                     .where(urgency_level:)
                                                     .where(action_name: "new_agreement_to_fill_in")
      new_agreement_to_fill_in_items.present? && new_agreement_to_fill_in_items.each do |item|
        do_not_resolve_conditions = item&.internship_agreement&.kept? &&
                                    item.internship_agreement&.draft?
        agreement_resolve(item.internship_agreement, user_id:) unless do_not_resolve_conditions
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

      # ------------------------
      # signatures_enabled case
      # ------------------------
      # "Conventions prêtes à être signées" is stale once the agreement has
      # been signed by all parties.
      signatures_enabled_items = MailActionItem.for_user(user_id)
                                               .where(urgency_level:)
                                               .where(action_name: "signatures_enabled")
      signatures_enabled_items.present? && signatures_enabled_items.each do |item|
        if item&.internship_agreement&.signed_by_all?
          item.update_columns(resolved_at: Time.current)
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

    def self.agreement_resolve(agreement, user_id:)
      return unless agreement.present? && agreement.persisted?

      MailActionItem.for_user(user_id)
                    .where(
                      action_type: :pending_internship_agreement,
                      internship_agreement_id: agreement.id
                    ).each do |item|
        item.update_columns(resolved_at: Time.current)
      end
    end
  end
end
