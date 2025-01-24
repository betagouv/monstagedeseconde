class CallbacksController < ApplicationController
  def fim
    if cookies[:state] == params[:state]
      code = params[:code]
      state = params[:state]

      user_info = Services::FimConnection.new(code, state).get_user_info
      redirect_to root_path, notice: 'Connexion impossible' and return unless user_info.present?

      unless School.exists?(code_uai: user_info['rne'])
        redirect_to root_path, alert: "Établissement non trouvé (UAI: #{user_info['rne']})" and return
      end

      user = User.find_or_initialize_by(email: user_info['email'])

      if user.persisted?
        sign_in(user)
        redirect_to root_path, notice: 'Vous êtes bien connecté'
      else
        user.first_name = user_info['given_name']
        user.last_name = user_info['family_name']
        user.email = user_info['email']
        user.password = make_password
        user.type = 'Users::SchoolManagement'
        user.role = get_role(user_info['FrEduFonctAdm'])
        user.school_id = get_school_id(user_info['rne'])

        user.confirmed_at = Time.now

        if user.save
          sign_in_and_redirect user, event: :authentication
        else
          puts user.errors.full_messages
          redirect_to root_path, alert: 'Erreur lors de la création de l\'utilisateur'
        end
      end
    else
      redirect_to root_path, alert: 'State invalide'
    end
  end

  def educonnect
    redirect_to root_path, alert: 'Jeton invalide' and return unless cookies[:state] == params[:state]

    code = params[:code]
    state = params[:state]
    nonce = params[:nonce]

    educonnect = Services::EduconnectConnection.new(code, state, nonce)

    session[:id_token] = educonnect.id_token
    session[:state] = state

    user_info = educonnect.get_user_info
    redirect_to root_path, notice: 'Connexion impossible' and return unless user_info.present?

    student = Users::Student.find_by(ine: user_info['FrEduCtEleveINE'])
    unless student.present?
      educonnect.logout
      redirect_to root_path, alert: 'Connexion non autorisée pour cet élève.' and return
    end

    student.confirm!

    sign_in(student)
    redirect_to after_sign_in_path_for(student), notice: 'Vous êtes bien connecté'
  end

  def get_role(role)
    case role
    when 'DIR'
      'school_manager'
    when 'ADF'
      'admin_officer'
    when 'ENS'
      'teacher'
    else
      'other'
    end
  end

  def get_school_id(uai)
    School.find_by(code_uai: uai).id
  end

  def make_password
    numbers = (0..9).to_a.sample(4)
    capitals = ('A'..'Z').to_a.sample(5)
    letters = ('a'..'z').to_a.sample(8)
    specials = ['!', '&', '+', '_', '@'].sample(3)
    (numbers + capitals + letters + specials).shuffle.join
  end
end
