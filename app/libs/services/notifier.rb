module Services
  class Notifier
    def broadcast_admins(info)
      # either all God::Users or a specific user in DEBUG_EMAIL_RECIPIENTS env var
      return unless Flipper.enabled?(flipper_feature.to_sym, user)

      GodMailer.debug_info(info: info, source: flipper_feature.to_s).deliver_later
    end

    private

    attr_reader :user, :flipper_feature

    def initialize(user:, flipper_feature:)
      @user = user
      @flipper_feature = flipper_feature
    end
  end
end
