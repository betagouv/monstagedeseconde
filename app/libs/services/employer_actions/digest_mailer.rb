module Services::EmployerActions
  class DigestMailer
    # should never be used in production, only for testing purposes
    def self.perform
      MailActionItem.involved_user_ids.each do |user_id|
        perform_for_low_level(user_id: user_id)
        perform_for_medium_level(user_id: user_id)
        perform_for_high_level(user_id: user_id)
        perform_for_critical_level(user_id: user_id)
      end
    end

    MailActionItem.urgency_levels.each_key do |urgency_level|
      define_singleton_method :"perform_for_#{urgency_level}_level" do |user_id:|
        manage_actions_before_delivery(user_id: user_id, level: urgency_level)

        actions = find_actions(user_id: user_id, urgency_level: urgency_level)
        return if actions.empty?

        EmployerActionsMailer.digest_email(
          user_id:,
          actions:,
          urgency_level: urgency_level
        ).deliver_later
        manage_actions_post_delivery(actions)
      end
    end

    def manage_actions_post_delivery(actions)
      actions.each do |action_type, items|
        items.each_with_index do |item, index|
          item.deliveries_count = item.deliveries_count + 1
          item.last_notified_at = Time.current
          item.save!
        end
      end
    end

    def self.manage_actions_before_delivery(user_id:, level:)
      mail_action_items_base = MailActionItem.where(user_id:)
                                             .where(urgency_level: level)
                                             .where(action_type: %i[pending_application])
      mail_action_items_base.where.not(resolved_at: nil)
                            .delete_all
      mail_action_items_base.where("stale_at < ?", Time.current)
                            .delete_all
      mail_action_items_base.where("deliveries_count >= max_deliveries_count")
                            .delete_all
    end

    def find_actions(user_id:, urgency_level:)
      actions = DigestBuilder.build_digest_by_user_and_urgency_level(
          user_id: user_id,
          urgency_level: urgency_level
        )
      return [] if actions.empty?

      actions = actions.select { |_action_type, items| items.any? }
      return [] if actions.empty?

      actions
    end
  end
end
