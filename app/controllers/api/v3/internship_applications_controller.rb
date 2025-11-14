# frozen_string_literal: true

module Api
  module V3
    class InternshipApplicationsController < ApplicationController
      include Api::AuthV2

      before_action :authenticate_api_user!, only: [:create, :new, :index]
      before_action :find_internship_offer, only: [:create, :new]
      before_action :find_student, only: [:create]

      def create
        check_required_params

        return if performed?

        # authorize! :apply, @internship_offer

        application_params = build_application_params
        @internship_application = InternshipApplication.new(application_params)

        if @internship_application.save
          Rails.logger.info "Internship application created successfully: #{@internship_application.id}"
          render_created
        else
          Rails.logger.error "Error creating internship application: #{@internship_application.errors.full_messages}"
          render_validation_error
        end
      end

      def new
        # return new internship application form
        render_error(code: 'FORBIDDEN', error: 'Only students can apply for internship offers', status: :forbidden) unless @current_api_user.student?

        render json: {
          student_phone: @current_api_user.phone,
          student_email: @current_api_user.email,
          representative_full_name: @current_api_user.legal_representative_full_name,
          representative_email: @current_api_user.legal_representative_email,
          representative_phone: @current_api_user.legal_representative_phone,
          weeks: available_weeks_for_form,
          motivation: '',
        }
      end

      def index
        puts 'in index'
        puts "current_api_user: #{@current_api_user.inspect}"
        Api::V2::StudentInternshipApplicationsFinder.new(
          student: @current_api_user,
          api_user: @current_api_user
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

      def find_internship_offer
        @internship_offer = InternshipOffer.find(params[:internship_offer_id])
      rescue ActiveRecord::RecordNotFound
        render_error(
          code: 'NOT_FOUND',
          error: 'Internship offer not found',
          status: :not_found
        )
      end

      def find_student
        puts 'in find_student'
        @student = Users::Student.where(id: params[:user_id]).first
      rescue ActiveRecord::RecordNotFound
        render_error(
          code: 'FORBIDDEN',
          error: 'Only students can apply for internship offers',
          status: :forbidden
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

        puts "Required params: #{required_params.inspect}"

        raise ActionController::ParameterMissing, :internship_application unless params[:internship_application]
        puts 'after raise'

        required_params.each do |param|
          unless params[:internship_application][param].present?
            puts "Missing required parameter: #{param}"
            render_error(
              code: 'MISSING_PARAMETER',
              error: "Missing required parameter: #{param}",
              status: :bad_request
            )
            return
          end
        end
      end

      def build_application_params
        sanitized_params = internship_application_params.to_h

        # Sanitize phone number
        if sanitized_params['student_phone']
          sanitized_params['student_phone'] = User.sanitize_mobile_phone_number(sanitized_params['student_phone'], '+33')
        end

        # Format week_ids
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

      def render_created
        render json: {
          id: @internship_application.id,
          uuid: @internship_application.uuid,
          internship_offer_id: @internship_application.internship_offer_id,
          student_id: @internship_application.user_id,
          aasm_state: @internship_application.aasm_state,
          submitted_at: @internship_application.submitted_at&.iso8601,
          motivation: @internship_application.motivation,
          student_phone: @internship_application.student_phone,
          student_email: @internship_application.student_email,
          student_address: @internship_application.student_address,
          student_legal_representative_full_name: @internship_application.student_legal_representative_full_name,
          student_legal_representative_email: @internship_application.student_legal_representative_email,
          student_legal_representative_phone: @internship_application.student_legal_representative_phone,
          weeks: @internship_application.weeks.map { |week| "#{week.year}-W#{week.number.to_s.rjust(2, '0')}" },
          created_at: @internship_application.created_at.iso8601,
          updated_at: @internship_application.updated_at.iso8601
        }, status: :created
      end

      def short_application_format(internship_application)
        {
          id: internship_application.id,
          uuid: internship_application.uuid,
          internship_offer_id: internship_application.internship_offer_id,
          student_id: internship_application.user_id,
          state: internship_application.aasm_state,
          internship_offer_title: internship_application.internship_offer.title,
          internship_offer_employer_name: internship_application.internship_offer.employer_name,
          internship_offer_address: internship_application.presenter(current_user).internship_offer_address,
          internship_offer_weeks: internship_application.presenter(current_user).str_weeks,
          created_at: internship_application.created_at.iso8601,
          updated_at: internship_application.updated_at.iso8601
        }
      end

      def render_validation_error
        render json: {
          error: 'VALIDATION_ERROR',
          message: 'The internship application could not be created',
          details: @internship_application.errors.full_messages
        }, status: :unprocessable_entity
      end

      def render_error(code:, error:, status:)
        render json: {
          error: code,
          message: error
        }, status: status
      end

      def available_weeks_for_form
        # For 3e student
        if @current_api_user.troisieme_ou_quatrieme?

          internship_application = InternshipApplication.new(
            internship_offer_id: @internship_offer.id,
            internship_offer_type: 'InternshipOffer',
            student: @current_api_user
          )

          available_weeks = internship_application.selectable_weeks
        else
          # For seconde student
          available_weeks = SchoolTrack::Seconde.both_weeks
        end

        available_weeks.map do |week|
          {
            id: week.id,
            label: week.human_select_text_method,
            selected: @current_api_user.troisieme_ou_quatrieme? ? internship_application.week_ids&.include?(week.id) : false
          }
        end
      end
    end
  end
end


