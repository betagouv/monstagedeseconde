# frozen_string_literal: true

module Admin
  class SchoolManagementsController < BaseController
    def index
      @query = params[:query].to_s.strip
      if @query.length >= 3
        @school_managements = Users::SchoolManagement
          .kept
          .search_by_query(@query)
          .order(:last_name, :first_name)
          .limit(20)
      else
        @school_managements = Users::SchoolManagement.none
      end
    end

    def show
      @school_management = Users::SchoolManagement.kept.find(params[:id])
      @primary_school    = @school_management.current_school
      @extra_schools     = @school_management.schools
                                             .where.not(id: @primary_school&.id)
                                             .order(:name)

      @school_query      = params[:school_query].to_s.strip
      if @school_query.length >= 3
        @schools = School.search_by_query(@school_query)
                         .where.not(id: @school_management.schools.select(:id))
                         .order(:name)
                         .limit(20)
      else
        @schools = School.none
      end
    end
  end
end
