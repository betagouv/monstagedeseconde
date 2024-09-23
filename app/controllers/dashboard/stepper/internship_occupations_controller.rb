# frozen_string_literal: true

module Dashboard::Stepper
  # Step 1 of internship offer creation: fill in company info
  class InternshipOccupationsController < ApplicationController
    before_action :authenticate_user!
    before_action :clean_params, only: %i[create update]

    # render step 1
    def new
      authorize! :create, InternshipOccupation

      puts 'new'

      @internship_occupation = InternshipOccupation.new
    end

    # process step 1
    def create
      authorize! :create, InternshipOccupation

      @internship_occupation ||= InternshipOccupation.new(internship_occupation_params)

      if @internship_occupation.save
        redirect_to new_dashboard_stepper_entreprise_path(internship_occupation_id: @internship_occupation.id)
      else
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
              :internship_street,
              :internship_zipcode,
              :internship_city,
              :description,
              :autocomplete,
              internship_coordinates: {}
            )
            .merge(employer_id: current_user.id)
      # :group_id,
      # :is_public,
      # :employer_website,
      # :manual_enter,
      # :employer_name,
      # :siret,
    end

    def clean_params
      params[:internship_occupation][:internship_street] =
        [params[:internship_occupation][:internship_street],
         params[:internship_occupation][:internship_street_complement]].compact_blank.join(' - ')
    end
  end
end
