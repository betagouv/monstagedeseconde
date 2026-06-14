module Services::EmployerActions
  class DigestBuilder
    def self.build_digest_by_user(user_id:)
      MailActionItem.urgency_levels.each_key do |level|
        @action_loops << build_digest_by_user_and_urgency_level(user_id: user_id, urgency_levels: [ level ])
      end
      @action_loops.compact!
    end

    def self.build_digest_by_user_and_urgency_level(user_id:, urgency_levels:)
      list_for_user = Services::EmployerActions::ActionList.new(user_id: user_id)
      list_for_user.by_urgency_level(urgency_levels: urgency_levels)
                   .to_h
                   .compact
    end

    attr_accessor :action_loops, :user_id
    def initialize(user_id:)
      @user_id = user_id
      @action_loops = []
    end
  end
end
