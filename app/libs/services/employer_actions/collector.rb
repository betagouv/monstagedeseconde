module Services::EmployerActions
  # Manage Captcha services
  class Collector
    def self.perform
      MailActionItem.involved_user_ids
                    .map { |user_id| perform_for_user(user_id: user_id) }
    end

    def self.perform_for_user(user_id:)
      ActionList.new(user_id: user_id).to_h
    end
  end
end
