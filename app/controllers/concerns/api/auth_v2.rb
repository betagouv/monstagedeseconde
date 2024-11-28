module Api
  module AuthV2
    extend ActiveSupport::Concern

    included do
      private

      def current_api_user
        decoded_token = JwtAuth.decode(token)
        return unless decoded_token

        @current_api_user ||= User.find(decoded_token[:user_id])
      end
    end
  end
end
