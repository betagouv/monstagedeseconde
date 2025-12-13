module Dashboard::MultiStepper
  class MultiPlanningsController < ApplicationController
    before_action :authenticate_user!
    before_action :fetch_multi_coordinator, only: %i[new create]
    before_action :fetch_multi_planning, only: %i[edit update]

    def new
      @multi_planning = MultiPlanning.new(
        multi_coordinator: @multi_coordinator,
        max_candidates: 1,
        all_year_long: true,
        grade_college: '1',
        grade_2e: '1',
      )
      # Force reload to ensure we have latest data
      @multi_corporation = MultiCorporation.find_by(id: params[:multi_corporation_id])
      puts "🔹 [MultiPlanningsController] MultiCorporation: #{@multi_corporation.inspect}"
      puts "🔹 [MultiPlanningsController] Corporations count: #{@multi_corporation&.corporations&.count}"
      set_weeks_variables
    end

    def create
      @multi_planning = MultiPlanning.new(multi_planning_params)
      @multi_planning.multi_coordinator = @multi_coordinator

      if @multi_planning.save
        # TODO: Redirect to recap or next step
        redirect_to dashboard_multi_stepper_multi_coordinator_path(@multi_coordinator), notice: 'Planning créé avec succès'
      else
        set_weeks_variables
        render :new, status: :bad_request
      end
    end

    def edit
      set_weeks_variables
    end

    def update
      if @multi_planning.update(multi_planning_params)
        redirect_to dashboard_multi_stepper_multi_coordinator_path(@multi_planning.multi_coordinator), notice: 'Planning mis à jour'
      else
        set_weeks_variables
        render :edit, status: :bad_request
      end
    end

    private

    def fetch_multi_coordinator
      @multi_coordinator = MultiCoordinator.find(params[:multi_coordinator_id])
    end

    def fetch_multi_planning
      @multi_planning = MultiPlanning.find(params[:id])
    end

    def multi_planning_params
      params.require(:multi_planning).permit(
        :max_candidates,
        :remaining_seats_count,
        :lunch_break,
        :multi_coordinator_id,
        :school_id,
        :rep,
        :qpv,
        :all_year_long,
        :grade_college,
        :grade_2e,
        :period_field,
        :internship_type,
        daily_hours: {},
        week_ids: [],
        grade_ids: [],
        weekly_hours: []
      )
    end
    
    def set_weeks_variables
      @available_weeks = Week.selectable_from_now_until_end_of_school_year
      @school_weeks = {}
      # @school_weeks = School.nearby_school_weeks(
      #   latitude: @internship_occupation.coordinates.latitude,
      #   longitude: @internship_occupation.coordinates.longitude,
      #   radius: DEFAULT_SCHOOL_RADIUS
      # )
    end
  end
end
