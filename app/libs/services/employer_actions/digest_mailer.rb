module Services::EmployerActions
  class DigestMailer
    MailActionItem.urgency_levels.each_key do |urgency_level|
      define_singleton_method :"perform_for_#{urgency_level}_level" do |user_id:|
        manage_actions_before_delivery(user_id: user_id, urgency_level: urgency_level)

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

    def self.manage_actions_before_delivery(user_id:, urgency_level:)
      Resolver.call(user_id:, urgency_level: urgency_level)
      mail_action_items_base = MailActionItem.where(user_id:)
                                             .where(urgency_level: urgency_level)
      mail_action_items_base.where.not(resolved_at: nil)
                            .delete_all
      mail_action_items_base.where("stale_at < ?", Time.current)
                            .delete_all
      mail_action_items_base.where("deliveries_count >= max_deliveries_count")
                            .delete_all
    end

    def self.manage_actions_post_delivery(actions)
      actions.each do |action_type, items|
        items.each do |item|
          item.deliveries_count = item.deliveries_count + 1
          item.last_notified_at = Time.current
          item.save!
        end
      end
    end

    def self.find_actions(user_id:, urgency_level:)
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
