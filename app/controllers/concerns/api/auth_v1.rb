module Api
  module AuthV1
    extend ActiveSupport::Concern

    included do
      private

      def current_api_user
        query = Users::Operator.where(api_token: token)
        @current_api_user ||= query.first
      end
    end
  end
end
