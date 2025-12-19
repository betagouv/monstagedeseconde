module Dashboard::MultiStepper
  class MultiCorporationsController < ApplicationController
    before_action :authenticate_user!
    before_action :fetch_multi_corporation, only: %i[edit update]

    def new
      @multi_coordinator = MultiCoordinator.find(params[:multi_coordinator_id])
      authorize! :create, MultiCorporation
      @multi_corporation = MultiCorporation.find_or_create_by!(multi_coordinator: @multi_coordinator)
      @corporation = Corporation.new(multi_corporation_id: @multi_corporation.id)
    end

    def create
      authorize! :create, MultiCorporation
      @multi_corporation = MultiCorporation.new(multi_corporation_params)
      
      if @multi_corporation.save
        redirect_to edit_dashboard_multi_stepper_multi_corporation_path(@multi_corporation)
      else
        render :new, status: :bad_request
      end
    end

    def edit
      authorize! :update, @multi_corporation
      @corporation = Corporation.new(multi_corporation_id: @multi_corporation.id)
    end

    def update
      authorize! :update, @multi_corporation
      
      if @multi_corporation.multi_coordinator.multi_planning
        redirect_to edit_dashboard_multi_stepper_multi_planning_path(@multi_corporation.multi_coordinator.multi_planning)
      else
        redirect_to new_dashboard_multi_stepper_multi_planning_path(multi_coordinator_id: @multi_corporation.multi_coordinator_id)
      end
    end

    private

    def fetch_multi_corporation
      @multi_corporation = MultiCorporation.find(params[:id])
    end

    def multi_corporation_params
      params.require(:multi_corporation).permit(:multi_coordinator_id)
    end
  end
end
