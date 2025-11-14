# frozen_string_literal: true

module Api
  module V3
    class InternshipApplicationsController < BaseController
      include Api::AuthV2
      include Api::V3::InternshipApplicationPresenter

      before_action :authenticate_api_user!, only: [:create, :new, :index]
      before_action :find_internship_offer, only: [:create, :new]

      def index
        Api::V2::StudentInternshipApplicationsFinder.new(
          student: @current_api_user,
          api_user: @current_api_user
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

      def find_internship_offer
        @internship_offer = InternshipOffer.find(params[:internship_offer_id])
      rescue ActiveRecord::RecordNotFound
        render_jsonapi_error(
          code: 'NOT_FOUND',
          detail: 'Internship offer not found',
          status: :not_found
        )
        false
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
    end
  end
end