module Services::CommonActions
  class BaseResolver
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

    def self.standard_resolver(user_id:, urgency_level:)
      base = MailActionItem.for_user(user_id).where(urgency_level:)
      base.where("stale_at < ?", Time.current).delete_all
      base.where("deliveries_count >= max_deliveries_count").delete_all
    end

    def self.extra_resolver(user_id:, urgency_level:)
      raise NotImplementedError, "#{name} must implement extra_resolver"
    end
  end
end
