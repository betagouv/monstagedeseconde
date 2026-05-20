class MagicLinksController < ApplicationController
  def show
    payload = JwtAuth.decode(params[:token])
    if payload && payload[:user_id] && MagicLinkToken.consume(payload[:jti])
      user = User.find_by(id: payload[:user_id])
      if user
        if user.otp_required_for_login?
          session[TwoFactorChallengesController::PENDING_SESSION_KEY] = user.id
          redirect_to two_factor_challenge_path,
                      notice: 'Lien validé. Confirmez avec votre application d’authentification.'
        else
          sign_in(user)
          redirect_to after_sign_in_path_for(user), notice: 'Connexion réussie.'
        end
        return
      end
    end
    redirect_to new_user_session_path, alert: 'Lien invalide ou expiré.'
  end
end
