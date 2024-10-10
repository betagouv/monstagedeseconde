# frozen_string_literal: true

class SchoolsController < ApplicationController
  before_action :authenticate_user!

  def new
    authorize! :new, School
    @school = School.new
  end

  def create
    authorize! :new, School
    @school = School.new(school_params)
    department = Department.fetch_by_zipcode(zipcode: @school.zipcode)
    @school.department = department
    if @school.save
      redirect_to root_path, flash: { success: 'Etablissement créé !' }
    else
      flash[:error] = "Erreur lors de la validation des informations : #{@school.errors.full_messages}"
      render :new
    end
  end

  private

  def school_params
    params.require(:school)
          .permit(
            :zipcode,
            :code_uai,
            :city,
            :street,
            :name,
            :visible,
            :contract_code,
            :is_public,
            coordinates: {}
          )
  end
end
