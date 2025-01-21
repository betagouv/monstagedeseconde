module Dashboard::Stepper
  class EntreprisesController < ApplicationController
    # step 2
    before_action :authenticate_user!
    before_action :fetch_entreprise, only: %i[edit update]

    def new
      @entreprise = Entreprise.new(internship_occupation_id: params[:internship_occupation_id])
      @internship_occupation = @entreprise.internship_occupation
      authorize! :create, @entreprise
      @duplication = false
      @edit_mode = false
    end

    def create
      @entreprise = Entreprise.new(entreprise_params)
      authorize! :create, @entreprise
      set_computed_params

      if @entreprise.save
        notice = "Les informations de l'entreprise ont bien été enregistrées"
        redirect_to new_dashboard_stepper_planning_path(entreprise_id: @entreprise.id), notice:
      else
        log_error(object: @entreprise)
        render :new, status: :bad_request
      end
    end

    def edit
      authorize! :edit, @entreprise
      @entreprise.entreprise_chosen_full_address = @entreprise.entreprise_full_address
      @duplication = false
      @edit_mode = true
    end

    # process update following a back to step 2
    def update
      authorize! :update, @entreprise
      set_computed_params
      if @entreprise.update(entreprise_params)
        if params[:planning_id].present? && Planning.find_by(id: params[:planning_id])
          redirect_to edit_dashboard_stepper_planning_path(
            entreprise_id: @entreprise.id,
            planning_id: params[:planning_id],
            id: params[:entreprise_id]
          )
        else
          redirect_to new_dashboard_stepper_planning_path(entreprise_id: @entreprise.id)
        end
      else
        log_error(object: @entreprise)
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
              :entreprise_street,
              :entreprise_zipcode,
              :entreprise_city,
              :employer_chosen_name,
              :entreprise_full_address,
              :entreprise_chosen_full_address,
              :entreprise_coordinates_longitude,
              :entreprise_coordinates_latitude,
              :contact_phone,
              :entreprise_coordinates,
              :internship_occupation_id,
              :internship_address_manual_enter,
              :workspace_conditions,
              :workspace_accessibility,
              :internship_address_manual_enter
            )
    end

    def set_computed_params
      @entreprise = set_updated_address_flag
      @entreprise.is_public ||= entreprise_params[:is_public] == 'true'
      @entreprise.entreprise_coordinates = { longitude: entreprise_params[:entreprise_coordinates_longitude],
                                             latitude: entreprise_params[:entreprise_coordinates_latitude] }
      @entreprise.entreprise_full_address = entreprise_params[:entreprise_chosen_full_address]
    end

    def set_updated_address_flag
      @entreprise.tap do |e|
        e.updated_entreprise_full_address = e.entreprise_full_address != entreprise_params[:entreprise_chosen_full_address]
      end
    end

    def fetch_entreprise
      id = params[:id] || params[:entreprise_id]
      @entreprise = Entreprise.find(id)
    end
  end
end
