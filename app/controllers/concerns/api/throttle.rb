# frozen_string_literal: true

module Api
  module Throttle
    extend ActiveSupport::Concern

    included do

      private
      
      def throttle_api_requests
        user_id = @current_api_user.id 
        key = "user:#{user_id}:#{Time.now.to_i / 60}"
        count = $redis.incr(key)
        $redis.expire(key, 60) if count == 1
  
        if count > InternshipOffers::Api::MAX_CALLS_PER_MINUTE
          render json: { error: "Trop de requêtes - Limite d'utilisation de l'API dépassée." }, status: :too_many_requests
        end
      end
    end
  end
end
