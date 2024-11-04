# frozen_string_literal: true

module Dashboard::Stepper
  # Step 1 of internship offer creation: fill in company info
  class InternshipOccupationsController < ApplicationController
    before_action :authenticate_user!
    before_action :clean_params, only: %i[create update]
    before_action :fetch_internship_occupation, only: %i[edit update]

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
        redirect_to new_dashboard_stepper_entreprise_path(internship_occupation_id: @internship_occupation.id,
                                                          submit_button: true),
                    notice: "L'adresse du stage et son intitulé ont bien été enregistrés"
      else
        log_error(object: @internship_occupation)
        render :new, status: :bad_request
      end
    end

    # render back to step 1
    def edit
      authorize! :edit, @internship_occupation
    end

    # process update following a back to step 1
    def update
      authorize! :update, @internship_occupation

      prevent_from_empty_coordinates
      if @internship_occupation.update(internship_occupation_params)
        @entreprise = Entreprise.find_by(id: params[:entreprise_id]) if params[:entreprise_id].present?
        if @entreprise.present?
          redirect_to edit_dashboard_stepper_entreprise_path(@entreprise)
        else
          redirect_to new_dashboard_stepper_entreprise_path(internship_occupation_id: @internship_occupation.id)
        end
      else
        log_error(object: @internship_occupation)
        render :new, status: :bad_request
      end
    end

    private

    def fetch_internship_occupation
      @internship_occupation = InternshipOccupation.find(params[:id])
    end

    def prevent_from_empty_coordinates
      return unless internship_occupation_params[:coordinates].nil?

      internship_occupation_params.merge!(former_coordinates)
    end

    def former_coordinates
      { coordinates: { latitude: @internship_occupation.coordinates.latitude,
                       longitude: @internship_occupation.coordinates.longitude } }
    end

    def internship_occupation_params
      params.require(:internship_occupation)
            .permit(
              :title,
              :description,
              :street,
              :street_complement,
              :zipcode,
              :city,
              :internship_address_manual_enter,
              :autocomplete,
              :employer_id,
              coordinates: {}
            )
    end

    def clean_params
      return if internship_occupation_params[:internship_address_manual_enter] == 'false'

      internship_occupation_params[:street] =
        [internship_occupation_params[:street],
         internship_occupation_params[:street_complement]].compact_blank.join(' - ')
    end
  end
end
