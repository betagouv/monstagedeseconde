class CallbacksController < ApplicationController
  def fim
    if true # cookies[:state] == params[:state]
      code = params[:code]
      state = params[:state]

      user_info = Services::FimConnection.new(code, state).get_user_info
      puts user_info.inspect
      redirect_to root_path, notice: 'Connexion impossible' unless user_info.present?

      user = User.find_or_initialize_by(email: user_info['email'])

      if user.persisted?
        sign_in(user)
        redirect_to root_path, notice: 'Vous êtes bien connecté'
      else
        # TODO: create user
        user.first_name = user_info['given_name']
        user.last_name = user_info['family_name']
        user.email = user_info['email']
        user.password = make_password
        user.type = 'Users::SchoolManagement'
        user.role = get_role(user_info['FrEduFonctAdm'])
        user.school_id = get_school_id(user_info['rne'])

        user.confirmed_at = Time.now
        user.save!

        sign_in_and_redirect user, event: :authentication
      end
    else
      redirect_to root_path, alert: 'State invalide'
    end
  end

  def get_role(role)
    case role
    when 'DIR'
      'school_manager'
    else
      'teacher'
    end
  end

  def get_school_id(uai)
    School.find_by(code_uai: uai).id
  end

  def make_password
    numbers = (0..9).to_a.sample(3)
    capitals = ('A'..'Z').to_a.sample(5)
    letters = ('a'..'z').to_a.sample(8)
    specials = ['!', '&', '+', '_', 'ç'].sample(2)
    (numbers + capitals + letters + specials).shuffle.join
  end
end
