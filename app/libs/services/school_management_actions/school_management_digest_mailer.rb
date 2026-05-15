module Services::SchoolManagementActions
  class SchoolManagementDigestMailer
    MailActionItem.urgency_levels.each_key do |urgency_level|
      # define "perform_for_low_level", "perform_for_medium_level", "perform_for_high_level" and "perform_for_critical_level" class methods
      define_singleton_method :"perform_for_#{urgency_level}_level" do |user_id:|
        urgency_levels = urgency_levels_sum_up(urgency_level)

        Resolver.call(user_id:, urgency_levels: urgency_levels)

        actions = find_actions(user_id: user_id, urgency_levels: urgency_levels)
        if actions.empty?
          Rails.logger.info "--------------------------------"
          Rails.logger.info "No pending and not overdue actions to notify for user #{user_id} at #{urgency_level} urgency level"
          Rails.logger.info "--------------------------------"
          return
        end

        EmployerActionsMailer.employer_digest_email(
          user_id:,
          actions:,
          urgency_levels: urgency_levels
        ).deliver_later
        manage_actions_post_delivery(actions)
      end
    end

    def self.manage_actions_post_delivery(actions)
      actions.each do |action_type, items|
        items.each do |item|
          # association with user is the reason why we don't use update_all here
          item.update_columns(
            deliveries_count: item.deliveries_count + 1,
            last_notified_at: Time.current
          )
        end
      end
    end

    def self.find_actions(user_id:, urgency_levels:)
      actions = ::Services::CommonActions::DigestBuilder.build_digest_by_user_and_urgency_level(
        user_id: user_id,
        urgency_levels: urgency_levels
      )
      return {} if actions.empty?

      actions = actions.select { |_action_type, items| items.any? }
      return {} if actions.empty?

      actions
    end

    def self.urgency_levels_sum_up(level)
      levels = MailActionItem.urgency_levels.keys
      idx = levels.index(level)
      return [] if idx.nil?

      levels[idx..]
    end
  end
end
