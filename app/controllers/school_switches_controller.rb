# frozen_string_literal: true

class SchoolSwitchesController < ApplicationController
  before_action :authenticate_user!
  before_action :set_school

  def create
    if current_user.switch_school(@school.id)
      redirect_to dashboard_school_class_rooms_path(@school),
                  notice: "Vous avez changé d'établissement"
    else
      redirect_back fallback_location: root_path, alert: "Impossible de changer d'établissement"
    end
  end

  private

  def set_school
    @school = current_user.schools.find(params[:school_id])
  end
end
