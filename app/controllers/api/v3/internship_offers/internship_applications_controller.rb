module Api
  module V3
    module InternshipOffers
      class InternshipApplicationsController < Api::Shared::InternshipApplicationsController
        include Api::AuthV2
        include Api::JsonApiRenderable
        include Api::V3::InternshipApplicationPresenter

        before_action :authenticate_api_user!, only: %i[new create]
        before_action :find_internship_offer, only: %i[new create]

        def index
          
          # return if performed?

          # formatted_internship_applications = Api::V2::StudentInternshipApplicationsFormatter.new(
          #   internship_applications: @internship_offer.internship_applications.to_a
          # ).format_all

          # render_jsonapi_collection(
          #   type: 'internship-application',
          #   records: formatted_internship_applications
          # )
        end

        def create
          check_user_is_student
          return if performed?

          check_required_params
          return if performed?

          internship_application = ::InternshipApplication.new(build_application_params)

          if internship_application.save
            render json: internship_application_payload(internship_application), status: :created
          else
            render_validation_error(internship_application)
          end
        end

        def new
          return if performed?

          unless @current_api_user.student?
            render_jsonapi_error(
              code: 'FORBIDDEN',
              detail: 'Only students can apply for internship offers',
              status: :forbidden
            )
            return
          end

          render json: internship_application_form_payload(
            user: @current_api_user,
            weeks: available_weeks_for_form
          ), status: :ok
        end

        private

        def find_internship_offer
          @internship_offer = ::InternshipOffer.find(params[:internship_offer_id])
        rescue ActiveRecord::RecordNotFound
          render_jsonapi_error(
            code: 'NOT_FOUND',
            detail: 'Internship offer not found',
            status: :not_found
          )
        end

        def check_required_params
          required_params = %i[
            student_phone
            student_email
            week_ids
            motivation
            student_address
            student_legal_representative_full_name
            student_legal_representative_email
            student_legal_representative_phone
          ]

          raise ActionController::ParameterMissing, :internship_application unless params[:internship_application]

          required_params.each do |param|
            next if params[:internship_application][param].present?

            render_jsonapi_error(
              code: 'MISSING_PARAMETER',
              detail: "Missing required parameter: #{param}",
              status: :bad_request
            )
            return
          end
        end

        def check_user_is_student
          unless @current_api_user.student?
            render_jsonapi_error(
              code: 'FORBIDDEN',
              detail: 'Only students can apply for internship offers',
              status: :forbidden
            )
            return
          end
        end

        def build_application_params
          sanitized_params = internship_application_params.to_h

          if sanitized_params['student_phone']
            sanitized_params['student_phone'] = User.sanitize_mobile_phone_number(
              sanitized_params['student_phone'],
              '+33'
            )
          end

          if sanitized_params['week_ids'].present?
            week_ids = sanitized_params['week_ids']
            week_ids = [week_ids] if week_ids.is_a?(String) && !week_ids.include?(',')
            week_ids = week_ids.split(',') if week_ids.is_a?(String) && week_ids.include?(',')
            sanitized_params['week_ids'] = week_ids.map(&:to_i)
          end

          sanitized_params.merge(
            user_id: @current_api_user.id,
            internship_offer_id: @internship_offer.id,
            internship_offer_type: @internship_offer.class.name
          )
        end

        def internship_application_params
          params.require(:internship_application)
                .permit(
                  :motivation,
                  :student_phone,
                  :student_email,
                  :student_address,
                  :student_legal_representative_full_name,
                  :student_legal_representative_email,
                  :student_legal_representative_phone,
                  week_ids: []
                )
        end

        def available_weeks_for_form
          if @current_api_user.troisieme_ou_quatrieme?
            internship_application = ::InternshipApplication.new(
              internship_offer_id: @internship_offer.id,
              internship_offer_type: 'InternshipOffer',
              student: @current_api_user
            )

            internship_application.selectable_weeks.map do |week|
              {
                id: week.id,
                label: week.human_select_text_method,
                selected: internship_application.week_ids&.include?(week.id)
              }
            end
          else
            ::SchoolTrack::Seconde.both_weeks.map do |week|
              {
                id: week.id,
                label: week.human_select_text_method,
                selected: false
              }
            end
          end
        end
      end
    end
  end
end
