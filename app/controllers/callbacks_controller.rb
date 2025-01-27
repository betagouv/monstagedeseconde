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
    # redirect_to root_path, alert: 'Jeton invalide' and return unless cookies[:state] == params[:state]

    code = params[:code]
    state = params[:state]
    nonce = params[:nonce]

    Rails.logger.info("Educonnect callback received with code present: #{code.present?}")
    Rails.logger.info("Educonnect callback received with state present: #{state.present?}")
    Rails.logger.info("Educonnect callback received with nonce present: #{nonce.present?}")

    educonnect = Services::EduconnectConnection.new(code, state, nonce)

    session[:id_token] = educonnect.id_token
    session[:state] = state

    Rails.logger.info("Educonnect ID token: #{educonnect.id_token}")

    user_info = educonnect.get_user_info
    redirect_to root_path, notice: 'Connexion impossible' and return unless user_info.present?

    student = Users::Student.find_by(ine: user_info['FrEduCtEleveINE'])
    school = School.find_by(code_uai: user_info['FrEduCtEleveUAI'])

    Rails.logger.info("School: #{school.inspect}")
    Rails.logger.info("Student: #{student.inspect}")

    unless school.present?
      handle_educonnect_logout(educonnect)
      redirect_to root_path,
                  alert: "Établissement scolaire non répertorié sur 1 élève, 1 stage (UAI: #{user_info['FrEduCtEleveUAI']})." and return
    end

    unless student.present?
      handle_educonnect_logout(educonnect)
      redirect_to root_path, alert: 'Elève non répertorié sur 1 élève, 1 stage.' and return
    end

    
    student.confirm
    student.save

    # if student.confirmed_at.blank?
    #   student.confirmed_at = Time.now
    #   student.save
    # end

    Rails.logger.info("Student confirmed at: #{student.confirmed_at}")

    begin
      Rails.logger.info("Starting sign in process...")
      Rails.logger.info("Student details - ID: #{student.id}, Email: #{student.email}")
      
      # Vérifier que l'utilisateur est valide avant la connexion
      unless student.valid?
        Rails.logger.error("Student validation failed: #{student.errors.full_messages}")
        return redirect_to root_path, alert: 'Erreur de validation utilisateur'
      end

      # Essayer de créer la session avec plus de détails en cas d'erreur
      # Devise.sign_out_all_scopes ? sign_in(student, scope: :user) : sign_in(student)
      sign_in(student)
      
      Rails.logger.info("Sign in successful - Session ID: #{session.id}")
      Rails.logger.info("Current user signed in: #{current_user&.id}")
    rescue StandardError => e
      Rails.logger.error("Failed to sign in student - Error type: #{e.class}")
      Rails.logger.error("Error message: #{e.message}")
      Rails.logger.error("Backtrace:\n#{e.backtrace.join("\n")}")
      return redirect_to root_path, alert: 'Erreur lors de la connexion'
    end

    Rails.logger.info("Student signed in successfully: #{user_signed_in?}")

    redirect_to root_path, notice: 'Vous êtes bien connecté'
    
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

  private

  def handle_educonnect_logout(educonnect)
    begin
      educonnect.logout
    rescue StandardError => e
      Rails.logger.error("Failed to logout from Educonnect: #{e.message}")
    ensure
      session.delete(:id_token)
      session.delete(:state)
    end
  end
end
