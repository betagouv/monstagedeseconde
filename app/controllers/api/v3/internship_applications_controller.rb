# frozen_string_literal: true

module Api
  module V3
    class InternshipApplicationsController < BaseController
      include Api::AuthV2
      include Api::JsonApiRenderable
      include Api::V3::InternshipApplicationPresenter

      before_action :authenticate_api_user!

      def index
        puts "index internship applications"
        internship_applications = InternshipApplication.where(user_id: @current_api_user.id)
                                                       .order(id: :desc)
                                                       .includes(:weeks, internship_offer: :employer)

        formatted_applications = internship_applications.map do |application|
          internship_application_payload(application)
        end

        render json: formatted_applications
      end
    end
  end
end