class MagicLinksController < ApplicationController
  def show
    payload = JwtAuth.decode(params[:token])
    if payload && payload[:user_id]
      user = User.find_by(id: payload[:user_id])
      if user
        sign_in(user)
        redirect_to after_sign_in_path_for(user), notice: 'Connexion réussie.'
        return
      end
    end
    redirect_to new_user_session_path, alert: 'Lien invalide ou expiré.'
  end
end
