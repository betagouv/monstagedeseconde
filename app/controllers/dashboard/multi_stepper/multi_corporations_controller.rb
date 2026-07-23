module Dashboard::MultiStepper
  class MultiCorporationsController < Dashboard::BaseController
    before_action :fetch_multi_corporation, only: %i[edit update]

    def new
      @multi_coordinator = MultiCoordinator.find(params[:multi_coordinator_id])
      authorize! :create, MultiCorporation
      @multi_corporation = MultiCorporation.find_or_create_by!(multi_coordinator: @multi_coordinator)
      @corporation = build_corporation_unless_full
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
      @corporation = build_corporation_unless_full
    end

    def update
      authorize! :update, @multi_corporation
      
      if @multi_corporation.multi_coordinator.multi_planning
        redirect_to edit_dashboard_multi_stepper_multi_planning_path(@multi_corporation.multi_coordinator.multi_planning, multi_corporation_id: @multi_corporation.id)
      else
        redirect_to new_dashboard_multi_stepper_multi_planning_path(multi_coordinator_id: @multi_corporation.multi_coordinator_id, multi_corporation_id: @multi_corporation.id)
      end
    end

    private

    # Stage partagé : pas de formulaire de 3e structure quand les 2 sont renseignées
    def build_corporation_unless_full
      return nil if @multi_corporation.full?

      Corporation.new(multi_corporation_id: @multi_corporation.id)
    end

    def fetch_multi_corporation
      @multi_corporation = MultiCorporation.find(params[:id])
    end

    def multi_corporation_params
      params.expect(multi_corporation: [:multi_coordinator_id])
    end
  end
end
