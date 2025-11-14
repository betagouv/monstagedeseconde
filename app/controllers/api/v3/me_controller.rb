# frozen_string_literal: true

module Api
  module V3
    class MeController < BaseController
      include Api::AuthV2

      before_action :authenticate_api_user!

      def show
        render_jsonapi_resource(
          type: 'user',
          record: user_payload
        )
      end

      private

      def user_payload
        user = current_api_user
        {
          id: user.id,
          email: user.email,
          first_name: user.first_name,
          last_name: user.last_name,
          role: user.class.name.demodulize.underscore,
          phone: user.try(:phone),
          school_id: user.try(:school_id),
          operator_id: user.try(:operator_id)
        }.compact
      end
    end
  end
end

