module Services::EmployerActions
  class ActionList
    attr_reader :user_id

    def initialize(user_id:)
      @user_id = user_id
    end

    def by_levels
      @by_level ||= MailActionItem.urgency_levels.keys.each_with_object({}) do |level, hash|
        level_actions = pending_actions.with_urgency_level(level)
        next if level_actions.empty?

        hash[level] = level_actions.to_a.group_by(&:action_type)
      end
    end

    def by_urgency_level(urgency_levels:)
      Array(urgency_levels).each_with_object({}) do |urgency_level, hash|
        grouped_actions = by_levels[urgency_level.to_s]
        next if grouped_actions.blank?

        grouped_actions.each do |action_type, items|
          hash[action_type] ||= []
          hash[action_type].concat(items)
        end
      end
    end

    def to_h
      { user_id => by_levels }
    end

    private

    def pending_actions
      @pending_actions ||= MailActionItem.for_user(user_id)
                                         .pending
                                         .not_overdue
    end
  end
end
