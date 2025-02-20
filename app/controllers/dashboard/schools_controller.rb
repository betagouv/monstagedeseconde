# frozen_string_literal: true

module Dashboard
  class SchoolsController < ApplicationController
    before_action :authenticate_user!
    before_action :set_school, only: %i[edit update show]

    def index
      authorize! :index, School
      query = School
      query = query.all if params[:visible].blank? || params[:rep_kind].blank?
      query = query.where(visible: parsed_visible_param) if params[:visible].present?
      query = query.where(rep_kind: parsed_kind_param) if internship_weeks_params[:rep_kind].present?
      query = query.where(qpv: internship_weeks_params[:qpv]) if internship_weeks_params[:qpv].present?
      query = query.order(zipcode: :desc)
      @schools = query.entries
    end

    def edit
      authorize! :edit, School
      @available_weeks = Week.selectable_on_school_year
    end

    def update
      authorize! :update, School
      @school.update!(internship_weeks_params)
      if current_user.god?
        redirect_to(dashboard_schools_path(anchor: "school_#{@school.id}"),
                    flash: { success: 'Etablissement mis à jour avec succès' })
      else
        redirect_to(dashboard_school_class_rooms_path(@school),
                    flash: { success: 'Etablissement mis à jour avec succès' })
      end
    rescue ActiveRecord::RecordInvalid
      @available_weeks = Week.selectable_on_school_year
      render :edit, status: :bad_request
    rescue ActionController::ParameterMissing
      @available_weeks = Week.selectable_on_school_year
      render :edit, status: :unprocessable_entity
    end

    def show
      authorize! :edit, School
      @available_weeks = Week.selectable_on_school_year
      redirect_to dashboard_school_class_rooms_path(@school)
    end

    private

    def set_school
      @school = School.find(params.require(:id))
    end

    def internship_weeks_params
      if current_user.god?
        god_internship_weeks_params
      else
        school_manager_internship_weeks_params
      end
    end

    def parsed_visible_param
      ActiveRecord::Type::Boolean.new.deserialize(params[:visible])
    end

    def parsed_kind_param
      if School::VALID_TYPE_PARAMS.include?(internship_weeks_params[:rep_kind])
        return internship_weeks_params[:rep_kind]
      end

      raise 'unknown kind'
    end

    def god_internship_weeks_params
      params.require(:school)
            .permit(:zipcode,
                    :city,
                    :street,
                    :name,
                    :visible,
                    :rep_kind,
                    :qpv,
                    :agreement_conditions_rich_text,
                    coordinates: {},
                    week_ids: [])
    end

    def school_manager_internship_weeks_params
      params.require(:school).permit(:agreement_conditions_rich_text, week_ids: [])
    end
  end
end
