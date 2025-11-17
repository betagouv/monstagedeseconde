# app/controllers/api/v1/auth_controller.rb
module Api
  module V3
    class AuthController < BaseController
      include Api::AuthV2

      def login
        user = User.find_by(email: params[:email])

        if user&.valid_password?(params[:password])
          token = JwtAuth.encode(user_id: user.id)
          render json: {
              token: token,
              user_id: user.id,
              issued_at: Time.current.iso8601}, status: :ok
        else
          render_jsonapi_error(
            code: 'UNAUTHORIZED',
            detail: 'Invalid email or password',
            status: :unauthorized
          )
        end
      end
    end
  end
end
