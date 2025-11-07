module Api
  module V2
    module Users
      class InternshipApplicationsController < Api::Shared::InternshipApplicationsController
        include Api::AuthV2
        before_action :authenticate_api_user!, only: %i[ index]
        before_action :find_user, only: %i[index]

        def index
          render_error(
            code: 'FORBIDDEN',
            error: 'Only students can apply for internship offers',
            status: :forbidden
          ) and return unless @user.student?

          Api::V2::StudentInternshipApplicationsFinder.new(
            student: @user,
            api_user: @user
          ).all => {internship_applications:, page_links:}

          formatted_internship_applications = Api::V2::StudentInternshipApplicationsFormatter.new(
            internship_applications: internship_applications.to_a
          ).format_all

          # data = {
          #   pagination: page_links,
          #   internshipApplications: formatted_internship_applications
          # }
          render json: formatted_internship_applications, status: 200
        end

        private

        def find_user
          @user = ::User.find_by(id: params[:user_id])
          render_error(
            code: 'NOT_FOUND',
            error: 'missing or invalid user_id',
            status: :unprocessable_entity
          ) and return if @user.nil?
        end
      end
    end
  end
end
