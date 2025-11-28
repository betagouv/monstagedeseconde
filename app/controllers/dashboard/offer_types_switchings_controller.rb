module Dashboard
  class OfferTypesSwitchingsController < ApplicationController
    before_action :authenticate_user!

    def new
      authorize! :create, InternshipOffer
    end

    def create
      authorize! :create, InternshipOffer

      case params[:offer_type_choice]
        when "for_my_company"
        redirect_to new_dashboard_stepper_internship_occupation_path
      when "for_another_company"
        redirect_to new_dashboard_stepper_internship_occupation_path
      when "for_multiple_companies"
        redirect_to new_dashboard_multi_stepper_multi_activity_path
      else
        flash.now[:alert] = "Veuillez sélectionner un type d'offre."
        render :new, status: :unprocessable_content
      end
    end
  end
end