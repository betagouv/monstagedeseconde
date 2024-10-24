# frozen_string_literal: true

module Dashboard::Stepper
  # Step 3 of internship offer creation: fill planning info
  class PlanningsController < ApplicationController
    before_action :authenticate_user!
    before_action :fetch_planning, only: %i[edit update]
    before_action :fetch_entreprise, only: %i[new create]

    def new
      @planning = Planning.new(
        all_year_long: true,
        grade_3e4e: true,
        grade_2e: true,
        entreprise_id: params[:entreprise_id]
      )
      authorize! :create, @planning
      @available_weeks = @planning.available_weeks || []
    end

    def create
      @planning = Planning.new(planning_params.merge(entreprise_id: params[:entreprise_id]))
      authorize! :create, @planning
      @available_weeks = @planning.available_weeks
      manage_planning_associations

      if @planning.save
        internship_offer_builder.create_from_stepper(**builder_params) do |on|
          on.success do |created_internship_offer|
            redirect_to(dashboard_internship_offer_path(created_internship_offer, origine: 'dashboard'),
                        notice: 'Les informations de planning ont bien été enregistrées. Votre offre est publiée')
          end
          on.failure do |failed_internship_offer|
            # @organisation = Organisation.find(params[:organisation_id])
            render :edit, status: :bad_request
          end
        end
      else
        # temporary debug
        puts "errors : @planning.errors : #{@planning.errors&.full_messages}" unless @planning.errors&.blank?
        # end temporary debug
        log_error(controller: self, object: @planning)
        render :new, status: :bad_request
      end
    end

    def edit
      authorize! :edit, @planning
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
              :grade_3e4e,
              :grade_2e,
              :lunch_break,
              :max_candidates,
              :max_students_per_group,
              :period,
              :school_id,
              :employer_id,
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
      @planning.grades = Grade.troisieme_et_quatrieme.to_a if planning_params[:grade_3e4e] == '1'
      @planning.grades.append Grade.seconde if planning_params[:grade_2e] == '1'
    end

    def manage_weeks
      @planning.weeks = @available_weeks if employer_chose_whole_year?
      return unless planning_params[:grade_2e] == '1'

      @planning.weeks << SchoolTrack::Seconde.both_weeks if planning_params[:period].to_i.zero?
      @planning.weeks << SchoolTrack::Seconde.first_week if planning_params[:period].to_i == 1
      @planning.weeks << SchoolTrack::Seconde.second_week if planning_params[:period].to_i == 2
    end

    def internship_offer_builder
      @builder ||= Builders::InternshipOfferBuilder.new(user: current_user, context: :web)
    end

    def fetch_planning
      @planning = Planning.find(params[:planning_id])
    end

    def fetch_entreprise
      @entreprise ||= Entreprise.find(params[:entreprise_id])
      # @internship_occupation ||= @entreprise.internship_occupation
    end

    def employer_chose_whole_year?
      params[:planning][:all_year_long] == 'true'
    end
  end
end
