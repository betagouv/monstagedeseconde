module Api
  module V2
    module Students
      class InternshipApplicationsController < Api::Shared::InternshipApplicationsController
        include Api::AuthV2

        def index
          student = Users::Student.find_by(id: params[:student_id])

          render_error(
            code: 'NOT_FOUND',
            error: 'missing or invalid student_id',
            status: :unprocessable_entity
          ) and return unless student

          Api::V2::StudentInternshipApplicationsFinder.new(
            student: student,
            api_user: current_api_user
          ).all => {internship_applications:, page_links:}

          formatted_internship_applications = Api::V2::StudentInternshipApplicationsFormatter.new(
            internship_applications: internship_applications.to_a
          ).format_all

          data = {
            pagination: page_links,
            internshipApplications: formatted_internship_applications
          }
          render json: data, status: 200
        end
      end
    end
  end
end
