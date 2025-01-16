class NewsletterController < ApplicationController
  def subscribe
    unless newsletter_email_checked?
      redirect_to root_path,
                  flash: { alert: "Votre email a l'air erroné" } and return
    end

    # our honeypot is filled, we don't subscribe this email, but pretend it's ok
    if fake_confirmation_filled?
      redirect_to root_path,
                  notice: 'Votre email a bien été enregistré' and return
    end

    user = User.new(email: params[:email])
    result = Services::SyncEmailCampaigns.new.add_contact(user: user)
    if success?(result)
      redirect_to root_path,
                  notice: 'Votre email a bien été enregistré' and return
    end

    duplicate_message = 'Votre email était déjà enregistré. :-) .'
    if result == :previously_existing_email
      redirect_to root_path,
                  flash: { warning: duplicate_message } and return
    end

    err_message = "Une erreur s'est produite et nous n'avons pas " \
                  'pu enregistrer votre email'
    redirect_to root_path, flash: { warning: err_message }
  end

  private

  def email_param
    params.permit(:newsletter_email, :newsletter_email_confirmation)
  end

  def fake_confirmation_filled?
    email_param[:newsletter_email_confirmation].present?
  end

  def success?(result)
    result.is_a?(Array) && result.size >= 4 && result[3] == email_param[:newsletter_email]
  end

  def newsletter_email_checked?
    params[:email].match?(/[^@ \t\r\n]+@[^@ \t\r\n]+\.[^@ \t\r\n]+/)
  end
end
