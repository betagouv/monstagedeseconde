# frozen_string_literal: true

class UsersController < ApplicationController
  include Phonable
  before_action :authenticate_user!
  skip_before_action :check_school_requested,
                     only: %i[edit update answer_survey]

  def edit
    authorize! :update, current_user
    split_phone_parts(current_user)
    redirect_to = account_path(section: :school)
    return unless force_select_school? && can_redirect?(redirect_to)

    redirect_to(redirect_to,
                flash: { danger: 'Veuillez rejoindre un etablissement' })
    nil
  end

  def update
    authorize! :update, current_user
    current_user.update!(user_params)
    redirect_back fallback_location: account_path, flash: { success: current_flash_message }
  rescue ActiveRecord::RecordInvalid
    render :edit, status: :bad_request
  end

  def update_password
    authorize! :update, current_user
    if password_change_allowed?
      current_user.update!(user_params)
      bypass_sign_in current_user
      redirect_to account_path(section: :password),
                  flash: { success: current_flash_message }
    else
      redirect_to account_path(section: :password),
                  flash: { warning: 'impossible de mettre à jour le mot de passe.' }
    end
  rescue ActiveRecord::RecordInvalid
    render :edit, status: :bad_request
  end

  def answer_survey
    current_user.update(survey_answered: true)
    render json: 'Survey answered', status: 200
  end

  def transform_input
    authorize! :transform_user, current_user
    @url = 'utilisateurs/transform_input'
    @user_mismatch = true
  end

  def transform_form
    authorize! :transform_user, current_user
    @user = User.kept.find_by(**search_hash)
    @user_mismatch = user_mismatch?
    if @user.nil?
      @error_message = 'Utilisateur inconnu'
    elsif @user&.anonymized?
      @error_message = 'Utilisateur déjà anonymisé'
    elsif !@user.employer?
      @error_message = "Cet utilisateur n'est pas un employeur"
    elsif @user.internship_offers.present?
      @error_message = 'Impossible de transformer cet employeur, car il a encore des offres'
    end
    render 'users/transform_input'
  end

  def transform_user
    authorize! :transform_user, current_user
    @error_message = nil
    user_to_transform = User.find(user_params[:id])
    if user_to_transform.internship_offers.present?
      @error_message = 'Impossible de transformer cet employeur, car il a encore des offres'
      render 'users/transform'
    elsif user_params[:role].present? && user_params[:school_id].present?
      user_to_transform.update_columns(role: user_params[:role],
                                       school_id: user_params[:school_id])
      user_to_transform.becomes!(Users::SchoolManagement)
                       .save!
      redirect_to '/admin', flash: { success: 'Utilisateur transformé avec succès.' }
    else
      @error_message = 'Impossible de transformer cet utilisateur à qui il manque une fonction ou une école.'
      render 'users/transform'
    end
  end

  def anonymize_form
    authorize! :anonymize_user, current_user
    render 'users/anonymize_form'
  end

  def identify_user
    authorize! :anonymize_user, current_user
    @user = User.kept.find_by(**search_hash)
    if @user && (@user.student? || @user.employer?)
      # @url = utilisateurs_anonymiser_path
    else
      @error_message = 'Utilisateur inconnu'
      if User.find_by(search_hash).try(:anonymized?)
        @error_message = 'Utilisateur déjà anonymisé'
      elsif @user.present? && !@user.employer? && !@user.student?
        @error_message = 'Ni un élève, ni un employeur'
      end
      # @url = utilisateurs_identifier_path
    end
    render 'users/anonymize_form'
  end

  def anonymize_user
    authorize! :anonymize_user, current_user
    user_to_anonymize = User.find(user_params[:id])
    if user_to_anonymize.anonymize(send_email: user_params[:anonymize_with_email] == 'true')
      redirect_to '/admin', flash: { success: 'Utilisateur anonymisé avec succès.' }
    else
      error_message = 'Impossible d’anonymiser cet utilisateur.'
      redirect_to '/admin', flash: { danger: error_message }
    end
  end

  helper_method :current_section

  private

  def current_flash_message
    message = if params.dig(:user, :missing_weeks_school_id).present?
              then "Nous allons prévenir votre chef d'établissement pour que vous puissiez postuler"
              else
                'Compte mis à jour avec succès.'
              end

    if current_user.unconfirmed_email
      message += " Pour confirmer le changement d’adresse électronique, \
                  veuillez cliquer sur lien contenu dans le courrier que \
                  vous venez de recevoir sur votre nouvelle adresse électronique."
    end
    message = 'Etablissement mis à jour avec succès.' if current_user.school_id_previously_changed?
    message
  end

  def user_params
    params.require(:user).permit(:id,
                                 :school_id,
                                 :missing_weeks_school_id,
                                 :agreement_signatorable,
                                 :first_name,
                                 :last_name,
                                 :email,
                                 :phone,
                                 :phone_prefix,
                                 :phone_suffix,
                                 :department,
                                 :class_room_id,
                                 :resume_other_tmp,
                                 :resume_languages_tmp,
                                 :password,
                                 :role,
                                 :birth_date,
                                 :academy_id,
                                 :academy_region_id,
                                 :employer_role,
                                 :phone_or_email,
                                 :anonymize_with_email,
                                 banners: {})
  end

  def current_section
    params[:section] || current_user.default_account_section
  end

  def force_select_school?
    current_user.missing_school? && current_section.to_s != 'school'
  end

  def can_redirect?(path)
    request.path != path
  end

  def password_change_allowed?
    current_user.valid_password?(params[:user][:current_password])
  end

  def search_hash
    form_input = user_params[:phone_or_email].strip
    search_hash = { phone: form_input }
    search_hash = { email: form_input } if form_input.match?(/\A[^@\s]+@[^@\s]+\z/)
    search_hash
  end

  def user_mismatch?
    @user.nil? ||
      !@user.employer? ||
      @user.discarded? ||
      @user.internship_offers.present?
  end
end
