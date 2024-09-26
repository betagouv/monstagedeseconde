# frozen_string_literal: true

module Dashboard::Stepper
  # Step 1 of internship offer creation: fill in company info
  class InternshipOccupationsController < ApplicationController
    before_action :authenticate_user!
    before_action :clean_params, only: %i[create update]

    # render step 1
    def new
      authorize! :create, InternshipOccupation

      @internship_occupation = InternshipOccupation.new
    end

    # process step 1
    def create
      authorize! :create, InternshipOccupation

      @internship_occupation ||= InternshipOccupation.new(internship_occupation_params)

      if @internship_occupation.save
        redirect_to new_dashboard_stepper_entreprise_path(internship_occupation_id: @internship_occupation.id),
                    notice: "L'adresse du stage et son intitulé ont bien été enregistrés"
      else
        log_error
        render :new, status: :bad_request
      end
    end

    # render back to step 1
    def edit
      @internship_occupation = InternshipOccupation.find(params[:id])
      authorize! :edit, @internship_occupation
    end

    # process update following a back to step 1
    def update
      @internship_occupation = InternshipOccupation.find(params[:id])
      authorize! :update, @internship_occupation

      if @internship_occupation.update(internship_occupation_params)
        if params[:entreprise_id].present? && Entreprise.find(params[:entreprise_id])
          redirect_to edit_dashboard_stepper_entreprise_path(
            internship_occupation_id: @internship_occupation.id,
            entreprise_id: params[:entreprise_id],
            planning_id: params[:planning_id],
            id: params[:entreprise_id]
          )
        else
          redirect_to new_dashboard_stepper_entreprise_path(internship_occupation_id: @internship_occupation.id)
        end
      else
        render :new, status: :bad_request
      end
    end

    private

    def internship_occupation_params
      params.require(:internship_occupation)
            .permit(
              :title,
              :description,
              :street,
              :zipcode,
              :city,
              :internship_address_manual_enter,
              :autocomplete,
              :employer_id,
              coordinates: {}
            ).merge(employer_id: current_user.id)
    end

    def clean_params
      params[:internship_occupation][:street] =
        [params[:internship_occupation][:street],
         params[:internship_occupation][:street_complement]].compact_blank.join(' - ')
    end

    def log_error
      Rails.logger.error(
        "InternshipOccupation creation error: #{@internship_occupation.errors.full_messages.join(', ')}"
      )
    end
  end
end
