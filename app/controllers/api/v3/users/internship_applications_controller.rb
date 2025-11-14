module Api
  module V3
    module Users
      class InternshipApplicationsController < Api::Shared::InternshipApplicationsController
        include Api::AuthV2
        include Api::JsonApiRenderable

        before_action :authenticate_api_user!, only: [:index]
        before_action :find_user, only: [:index]

        def index
          unless @user.student?
            render_jsonapi_error(
              code: 'FORBIDDEN',
              detail: 'Only students can apply for internship offers',
              status: :forbidden
            )
            return
          end

          Api::V2::StudentInternshipApplicationsFinder.new(
            student: @user,
            api_user: @user
          ).all => {internship_applications:, page_links:}

          formatted_internship_applications = Api::V2::StudentInternshipApplicationsFormatter.new(
            internship_applications: internship_applications.to_a
          ).format_all

          render_jsonapi_collection(
            type: 'internship-application',
            records: formatted_internship_applications,
            meta: { pagination: page_links }
          )
        end

        private

        def find_user
          @user = ::User.find_by(id: params[:user_id])
          return if @user

          render_jsonapi_error(
            code: 'NOT_FOUND',
            detail: 'missing or invalid user_id',
            status: :unprocessable_entity
          )
          false
        end
      end
    end
  end
end
