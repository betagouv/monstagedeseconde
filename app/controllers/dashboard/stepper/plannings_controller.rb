# frozen_string_literal: true

module Dashboard::Stepper
  # Step 3 of internship offer creation: fill planning info
  class PlanningsController < ApplicationController
    before_action :authenticate_user!
    before_action :fetch_planning, only: %i[edit update]
    before_action :fetch_entreprise, only: %i[new]

    def new
      @planning = Planning.new(
        internship_occupation_id: @internship_occupation.id,
        entreprise_id: @entreprise.id
      )
      @available_weeks = @planning.available_weeks
    end

    def create
      @planning = Planning.new(planning_params)

      @planning.weeks = @planning.available_weeks if  employer_chose_whole_year?
      byebug


      puts "@planning.errors.full_messages : #{@planning.errors.full_messages}" unless @planning.valid?
      puts '================================'
      puts ''

      ActiveRecord::Base.transaction do
        if @planning.save
          @planning.grades = Grade.troisieme_et_quatrieme if planning_params[:grade_3e4e] == 'true'

          #                                              user: current_user,
          #                                              organisation: Organisation.find(params[:organisation_id]),
          #                                              internship_offer_info: InternshipOfferInfo.find(params[:internship_offer_info_id]),
          #                                              hosting_info: HostingInfo.find(params[:hosting_info_id]),
          #                                              practical_info: @practical_info) do |on|
          #   on.success do |created_internship_offer|
          #     redirect_to(internship_offer_path(internship_offer, origine: 'dashboard'),
          #                 flash: { success: 'Votre offre de stage est prête à être publiée.' })
          #   end
          #   on.failure do |failed_internship_offer|
          #     # @organisation = Organisation.find(params[:organisation_id])
          #     render :edit, status: :bad_request
          #   end
          # end

          notice = 'Les informations de planning ont bien été enregistrées. Votre offre est publiée'
          # redirect_to dashboard_internship_offer_path(@internship_offer.id), notice:
          # TEMPRORARY REDIRECT
          redirect_to dashboard_internship_offers_path, notice:
        else
          log_error(controller: self, object: @planning)
          render :new, status: :bad_request
        end
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
            internship_occupation_id: params[:internship_occupation_id],
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
              :entreprise_id,
              :internship_occupation_id,
              :weekly_lunch_break,
              :entreprise_id,
              :internship_occupation_id,
              :max_candidates,
              :max_students_per_group
            )
      # :max_candidates,
      # :max_students_per_group,
      # :weekly_hours,
      # :daily_hours,
      # :daily_lunch_break,
      # :school_id,
    end

    def builder_params
      {
        user: current_user,
        entreprise: Entreprise.find(params[:entreprise_id]),
        internship_occupation: entreprise.internship_occupation,
        planning: @planning
      }
    end

    def internship_offer_builder
      @builder ||= Builders::InternshipOfferBuilder.new(user: current_user,
                                                        context: :web)
    end

    def fetch_planning
      @planning = Planning.find(params[:planning_id])
    end

    def fetch_entreprise
      @entreprise = Entreprise.find(params[:entreprise_id])
      @internship_occupation = @entreprise.internship_occupation
    end

    def employer_chose_whole_year?
      params[:planning][:all_year_long] == 'true'
    end
  end
end
