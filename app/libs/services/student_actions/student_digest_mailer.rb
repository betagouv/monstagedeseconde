module Services::StudentActions
  class StudentDigestMailer
    MailActionItem.urgency_levels.each_key do |urgency_level|
      define_singleton_method :"perform_for_#{urgency_level}_level" do |user_id:|
        urgency_levels = urgency_levels_sum_up(urgency_level)

        Resolver.call(user_id:, urgency_levels:)

        actions = find_actions(user_id:, urgency_levels:)
        if actions.empty?
          Rails.logger.info "--------------------------------"
          Rails.logger.info "No pending and not overdue actions to notify for student #{user_id} at #{urgency_level} urgency level"
          Rails.logger.info "--------------------------------"
          return
        end

        StudentActionsMailer.student_digest_email(
          user_id:,
          actions:,
          urgency_levels:
        ).deliver_later
        manage_actions_post_delivery(actions)
      end
    end

    def self.manage_actions_post_delivery(actions)
      actions.each do |_action_type, items|
        items.each do |item|
          item.update_columns(
            deliveries_count: item.deliveries_count + 1,
            last_notified_at: Time.current
          )
        end
      end
    end

    def self.find_actions(user_id:, urgency_levels:)
      actions = ::Services::CommonActions::DigestBuilder.build_digest_by_user_and_urgency_level(
        user_id:,
        urgency_levels:
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
