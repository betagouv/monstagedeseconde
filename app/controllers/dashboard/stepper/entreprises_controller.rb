module Dashboard::Stepper
  class EntreprisesController < ApplicationController
    # step 2
    before_action :authenticate_user!
    before_action :fetch_entreprise, only: %i[edit update]

    def new
      @entreprise = Entreprise.new(internship_occupation_id: params[:internship_occupation_id])
    end

    def create
      @entreprise = Entreprise.new(entreprise_params)
      @entreprise.entreprise_coordinates = { longitude: entreprise_params[:entreprise_coordinates_longitude],
                                             latitude: entreprise_params[:entreprise_coordinates_latitude] }
      @entreprise = set_updated_address_flag(@entreprise, entreprise_params)

      if @entreprise.save
        path_params = {
          entreprise_id: @entreprise.id,
          internship_occupation_id: @entreprise.internship_occupation_id
        }
        notice = "Les informations de l'entreprise ont bien été enregistrées"
        redirect_to new_dashboard_stepper_planning_path(path_params), notice:
      else
        log_error
        render :new, status: :bad_request
      end
    end

    def edit
      authorize! :edit, @entreprise
    end

    # process update following a back to step 2
    def update
      authorize! :update, @entreprise
      if @entreprise.update(entreprise_params)
        if params[:planning_id].present? && Planning.find_by(id: params[:planning_id])
          redirect_to edit_dashboard_stepper_planning_path(
            entreprise_id: @entreprise.id,
            internship_occupation_id: params[:internship_occupation_id],
            planning_id: params[:planning_id],
            id: params[:entreprise_id]
          )
        else
          log_error
          redirect_to new_dashboard_stepper_entreprise_path(entreprise_id: @entreprise.id)
        end
      else
        log_error
        render :new, status: :bad_request
      end
    end

    private

    def entreprise_params
      params.require(:entreprise)
            .permit(
              :siret,
              :is_public,
              :group_id,
              :sector_id,
              :employer_name,
              :employer_chosen_name,
              :entreprise_full_address,
              :entreprise_chosen_full_address,
              :entreprise_coordinates_longitude,
              :entreprise_coordinates_latitude,
              :tutor_first_name,
              :tutor_last_name,
              :tutor_email,
              :tutor_phone,
              :tutor_function,
              :internship_occupation_id
            )
      # :group_id
    end

    def set_updated_address_flag(entreprise, parameter)
      entreprise.tap do |e|
        e.updated_entreprise_full_address = e.entreprise_full_address != parameter[:entreprise_chosen_full_address]
      end
    end

    def fetch_entreprise
      @entreprise = Entreprise.find(params[:entreprise_id])
    end

    def log_error
      Rails.logger.error(
        "Entreprise creation error: #{@entreprise.errors.full_messages.join(', ')}"
      )
    end
  end
end
