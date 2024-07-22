# frozen_string_literal: true

class PagesController < ApplicationController
  WEBINAR_URL = ENV.fetch('WEBINAR_URL').freeze
  layout 'homepage', only: %i[home
                              pro_landing
                              regional_partners_index
                              school_management_landing
                              statistician_landing
                              student_landing
                              search_companies
                              maintenance_estivale]

  def register_to_webinar
    authorize! :subscribe_to_webinar, current_user
    current_user.update(subscribed_to_webinar_at: Time.zone.now)
    redirect_to WEBINAR_URL,
                allow_other_host: true
  end

  def offers_with_sector
    InternshipOffer.includes([:sector])
  end

  def student_landing
  end

  def search_companies
  end

  def maintenance_messaging
    hash = {
      subject: "Message de la page de maintenance de #{user_params[:name]}",
      message: user_params[:message],
      name: user_params[:name],
      email: user_params[:email]
    }

    GodMailer.maintenance_mailing(**hash).deliver_later
    redirect_to '/maintenance_estivale.html', notice: 'Votre message a bien été envoyé'
  end

  def user_params
    params.require(:user).permit(:name, :email, :message)
  end

  alias_method :school_management_landing, :student_landing
  alias_method :statistician_landing, :student_landing
end
