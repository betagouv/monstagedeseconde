# frozen_string_literal: true

module Dashboard::Multi
  # Step 2 of multi-activity internship offer creation: coordinator information
  class MultiCoordinatorsController < ApplicationController
    before_action :authenticate_user!
    before_action :fetch_multi_coordinator, only: %i[edit update]
    before_action :sanitize_content, only: %i[create update]

    def new
      @multi_activity = MultiActivity.find(params[:multi_activity_id])
      @multi_coordinator = MultiCoordinator.new(multi_activity_id: @multi_activity.id)
      authorize! :create, @multi_coordinator
    end

    def create
      @multi_activity = MultiActivity.find(params[:multi_coordinator][:multi_activity_id])
      @multi_coordinator = MultiCoordinator.new(multi_coordinator_params)
      authorize! :create, @multi_coordinator

      set_computed_params

      if @multi_coordinator.save
        notice = "Les informations du coordinateur ont bien été enregistrées"
        multi_corporation = MultiCorporation.find_or_create_by!(multi_coordinator: @multi_coordinator)
        redirect_to edit_dashboard_multi_multi_corporation_path(multi_corporation), notice: notice
      else
        log_error(object: @multi_coordinator)
        render :new, status: :bad_request
      end
    end

    def edit
      authorize! :edit, @multi_coordinator
      @multi_activity = @multi_coordinator.multi_activity
    end

    def update
      authorize! :update, @multi_coordinator
      @multi_activity = @multi_coordinator.multi_activity
      set_computed_params

      if @multi_coordinator.update(multi_coordinator_params)
        multi_corporation = MultiCorporation.find_or_create_by!(multi_coordinator: @multi_coordinator)
        redirect_to edit_dashboard_multi_multi_corporation_path(multi_corporation)
      else
        log_error(object: @multi_coordinator)
        render :new, status: :bad_request
      end
    end

    private

    def fetch_multi_coordinator
      id = params[:id] || params[:multi_coordinator_id]
      @multi_coordinator = MultiCoordinator.find(id)
    end

    def multi_coordinator_params
      params.require(:multi_coordinator)
            .permit(:siret,
                    :sector_id,
                    :employer_name,
                    :employer_chosen_name,
                    :employer_address,
                    :employer_chosen_address,
                    :city,
                    :zipcode,
                    :street,
                    :phone,
                    :multi_activity_id)
    end

    def set_computed_params
      @multi_coordinator.employer_chosen_name ||= multi_coordinator_params[:employer_name]
      @multi_coordinator.employer_chosen_address ||= multi_coordinator_params[:employer_address]
    end

    def sanitize_content
      # No content to sanitize for now
    end
  end
end

