# app/controllers/api/v1/auth_controller.rb
module Api
  module V2
    class AuthController < ApplicationController
      skip_before_action :verify_authenticity_token
      include Api::AuthV2

      def login
        user = User.find_by(email: params[:email])
        if user&.valid_password?(params[:password])
          token = JwtAuth.encode(user_id: user.id)
          render json: { token: token }, status: :ok
        else
          render json: { error: 'Invalid email or password' }, status: :unauthorized
        end
      end
    end
  end
end
