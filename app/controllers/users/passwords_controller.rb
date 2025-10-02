# frozen_string_literal: true

module Users
  class PasswordsController < Devise::PasswordsController
    include Phonable
    def create
      if by_phone? && fetch_user_by_phone.nil?
        redirect_to(
          new_user_password_path,
          flash: { alert: I18n.t('errors.messages.unknown_phone_number') }
        )
        return
      elsif by_phone? && fetch_user_by_phone
        @user.reset_password_by_phone
        redirect_to phone_edit_password_path(phone: safe_phone_param)
        return
      end

      super
    end

    def edit
      # Hash the raw token to find the user
      hashed_token = Devise.token_generator.digest(User, :reset_password_token, params['reset_password_token'])
      @current_user = User.find_by_reset_password_token(hashed_token)
      if @current_user
        @teacher = User.find(params['teacher_id']) if params['teacher_id'].present?
        super
      else
        redirect_to new_user_password_path, flash: { alert: 'Jeton de réinitialisation du mot de passe invalide.' }
      end
    end

    def update
      super      
      # Remove the token after successful update
      if resource&.persisted? && resource.errors.empty?
        resource.update(reset_password_token: nil, reset_password_sent_at: nil)
      end
    end

    def edit_by_phone; end

    def set_up
    end
  end
end
