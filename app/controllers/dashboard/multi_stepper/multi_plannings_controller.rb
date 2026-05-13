module Dashboard::MultiStepper
  class MultiPlanningsController < ApplicationController
    before_action :authenticate_user!
    before_action :fetch_multi_coordinator, only: %i[new create]
    before_action :fetch_multi_planning, only: %i[edit update]
    before_action :fetch_multi_corporation, only: %i[new create edit update]

    def new
      @multi_planning = MultiPlanning.new(
        multi_coordinator: @multi_coordinator,
        max_candidates: 1,
        all_year_long: true,
        grade_college: '1',
        grade_2e: '1',
      )
      set_weeks_variables
    end

    def create
      @multi_planning = MultiPlanning.new(multi_planning_params)
      @multi_planning.multi_coordinator = @multi_coordinator

      @multi_planning = Dto::MultiPlanningAdapter.new(instance: @multi_planning,
                                                      params: multi_planning_params,
                                                      current_user: current_user)
                                                 .manage_planning_associations
                                                 .instance

      if @multi_planning.save
        builder = Builders::MultiInternshipOfferBuilder.new(user: current_user, context: :web)
        builder.create_from_stepper(user: current_user, multi_planning: @multi_planning) do |on|
          on.success do |created_internship_offer|
            redirect_to(internship_offer_path(created_internship_offer, origine: 'dashboard', stepper: true),
                        notice: 'Les informations de planning ont bien été enregistrées. Votre offre est publiée')
          end
          on.failure do |failed_internship_offer|
            flash.now[:alert] = "Erreur lors de la création de l'offre: #{failed_internship_offer.errors.full_messages.join(', ')}"
            set_weeks_variables
            render :new, status: :bad_request
          end
        end
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

    def fetch_multi_corporation
      @multi_corporation = MultiCorporation.find_by(id: params[:multi_corporation_id])
    end

    def multi_planning_params
      params.expect(
        multi_planning: [
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
          weekly_hours: [],
          school_ids: []
      ])
    end

    def set_weeks_variables
      @available_weeks = Week.selectable_from_now_until_end_of_school_year

      first_corp = @multi_corporation.corporations.first
      coordinates = first_corp.internship_coordinates

      @school_weeks = School.nearby_school_weeks(
        latitude: coordinates.latitude,
        longitude: coordinates.longitude,
        radius: 60_000
      )
    end
  end
end
