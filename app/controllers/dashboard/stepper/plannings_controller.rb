# frozen_string_literal: true

module Dashboard::Stepper
  # Step 3 of internship offer creation: fill planning info
  class PlanningsController < ApplicationController
    before_action :authenticate_user!
    before_action :fetch_planning, only: %i[edit update]
    before_action :fetch_entreprise, only: %i[new create]
    before_action :fetch_internship_occupation, only: %i[new edit create]

    PERIOD = {
      two_weeks: 2,
      first_week: 11,
      second_week: 12
    }
    DEFAULT_SCHOOL_RADIUS = 60_000 # 60km

    def new
      @planning = Planning.new(
        all_year_long: true,
        grade_college: '1',
        grade_2e: '1',
        entreprise_id: params[:entreprise_id]
      )
      authorize! :create, @planning
      @internship_occupation = @entreprise.internship_occupation
      @available_weeks = @planning.available_weeks || []
      @school_weeks = School.nearby_school_weeks(
        latitude: @internship_occupation.coordinates.latitude,
        longitude: @internship_occupation.coordinates.longitude,
        radius: DEFAULT_SCHOOL_RADIUS
      )
    end

    def create
      @planning = Planning.new(planning_params.merge(entreprise_id: params[:entreprise_id]))
      authorize! :create, @planning
      @available_weeks = @planning.available_weeks
      manage_planning_associations

      if @planning.save
        internship_offer_builder.create_from_stepper(**builder_params) do |on|
          on.success do |created_internship_offer|
            redirect_to(internship_offer_path(created_internship_offer, origine: 'dashboard', stepper: true),
                        notice: 'Les informations de planning ont bien été enregistrées. Votre offre est publiée')
          end
          on.failure do |failed_internship_offer|
            render :edit, status: :bad_request
          end
        end
      else
        log_error(object: @planning)
        render :new, status: :bad_request
      end
    end

    def edit
      authorize! :edit, @planning
      @school_weeks = School.nearby_school_weeks(
        latitude: @internship_occupation.coordinates.latitude,
        longitude: @internship_occupation.coordinates.longitude,
        radius: DEFAULT_SCHOOL_RADIUS
      )
    end

    # process update following a back to step 2
    def update
      authorize! :update, @planning

      if @planning.update(planning_params)
        if params[:planning_id].present? && Planning.find_by(id: params[:planning_id])
          redirect_to edit_dashboard_stepper_planning_path(
            planning_id: @planning.id,
            id: params[:planning_id]
          )
        else
          redirect_to new_dashboard_stepper_planning_path(planning_id: @planning.id)
        end
      else
        render :new, status: :bad_request
      end
    end

    private

    def planning_params
      params.require(:planning)
            .permit(
              :all_year_long,
              :grade_college,
              :grade_2e,
              :lunch_break,
              :max_candidates,
              :max_students_per_group,
              :period,
              :school_id,
              :weeks_count,
              daily_hours: {},
              weekly_hours: [],
              week_ids: []
            )
    end

    def builder_params
      {
        user: current_user,
        planning: @planning
      }
    end

    def manage_planning_associations
      manage_grades
      manage_weeks
      @planning.employer_id = current_user.id
    end

    def manage_grades
      @planning.grades = Grade.troisieme_et_quatrieme.to_a if params_offer_for_troisieme_or_quatrieme?
      @planning.grades.append Grade.seconde if params_offer_for_seconde?
    end

    def manage_weeks
      # @planning.weeks = @available_weeks if employer_chose_whole_year? # legacy
      @planning.internship_weeks_number = 1
      return unless params_offer_for_seconde?

      @planning.weeks = [] unless params_offer_for_troisieme_or_quatrieme?
      case period
      when PERIOD[:two_weeks]
        @planning.internship_weeks_number = 2
        @planning.weeks << SchoolTrack::Seconde.both_weeks
      when PERIOD[:first_week]
        @planning.weeks << SchoolTrack::Seconde.first_week
      when PERIOD[:second_week]
        @planning.weeks << SchoolTrack::Seconde.second_week
      end
    end

    def params_offer_for_seconde?
      planning_params[:grade_2e].to_i == 1
    end

    def params_offer_for_troisieme_or_quatrieme?
      planning_params[:grade_college].to_i == 1
    end

    def period
      planning_params[:period].to_i
    end

    def internship_offer_builder
      @builder ||= Builders::InternshipOfferBuilder.new(user: current_user, context: :web)
    end

    def fetch_planning
      @planning = Planning.find(params[:planning_id])
    end

    def fetch_entreprise
      @entreprise ||= Entreprise.find(params[:entreprise_id])
    end

    def fetch_internship_occupation
      @internship_occupation ||= @entreprise&.internship_occupation || @planning&.entreprise&.internship_occupation
    end

    def employer_chose_whole_year?
      params[:planning][:all_year_long] == 'true'
    end
  end
end
