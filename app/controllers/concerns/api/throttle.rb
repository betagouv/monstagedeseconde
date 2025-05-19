# frozen_string_literal: true

module Api
  module Throttle
    extend ActiveSupport::Concern

    included do
      private

      def throttle_api_requests(service, max_calls_per_minute)
        return unless @current_api_user

        user_id = @current_api_user.id
        key = "user:#{user_id}:#{service}:#{Time.now.to_i / 60}"
        store_or_render_error(key, max_calls_per_minute, "Trop de requêtes - Limite d'utilisation de l'API dépassée." )
      end

      def site_throttle_api_requests(service, max_calls_per_minute)
        key = "#{service}:#{Time.now.to_i / 60}"
        store_or_render_error(key, max_calls_per_minute, "Trop de requêtes - Limite d'utilisation de l'API dépassée." )
      end

      def store_or_render_error(key, max_calls_per_minute, error)
        count = $redis.incr(key)
        $redis.expire(key, 60) if count == 1

        return unless count > max_calls_per_minute

        render json: { error: error }, status: :too_many_requests
      end
    end
  end
end
