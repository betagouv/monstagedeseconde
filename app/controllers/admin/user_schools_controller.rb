# frozen_string_literal: true

module Admin
  class UserSchoolsController < BaseController
    before_action :load_school_management

    def create
      @school = School.find(params[:school_id])
      @user_school = UserSchool.new(user: @school_management, school: @school)

      if @user_school.save
        @extra_schools = extra_schools
        @notice = "#{@school.name} associé avec succès."
      else
        @error = @user_school.errors.full_messages.to_sentence
      end
    end

    def destroy
      @user_school = UserSchool.find(params[:id])
      @school      = @user_school.school
      @user_school.destroy!
      @extra_schools = extra_schools
      @notice = "Association avec #{@school.name} supprimée."
    rescue ActiveRecord::RecordNotFound
      @error = "Association introuvable."
    end

    private

    def load_school_management
      @school_management = Users::SchoolManagement.kept.find(params[:school_management_id])
    end

    def extra_schools
      @school_management.schools
                        .where.not(id: @school_management.current_school&.id)
                        .order(:name)
    end
  end
end
