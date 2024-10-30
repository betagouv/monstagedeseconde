# frozen_string_literal: true

module Dashboard
  class InternshipApplicationsController < ApplicationController
    before_action :authenticate_user!

    def index
      authorize! :create, InternshipAgreement
      @internship_offer_areas = current_user.internship_offer_areas
      @internship_applications = current_user.internship_applications
                                             .filtering_discarded_students
                                             .approved
    end

    def update_multiple
      authorize! :update_multiple, InternshipApplication
      @internship_applications = InternshipApplication.where(id: params[:ids].split(','))

      begin
        ActiveRecord::Base.transaction do
          @internship_applications.each do |internship_application|
            unless valid_transition?(params[:transition])
              raise ArgumentError, "Transition non autorisée: #{params[:transition]}"
            end

            internship_application.public_send(params[:transition])

            internship_application.update!(rejected_message: params[:rejection_message])
          end
        end
        redirect_to dashboard_candidatures_path, notice: 'Les candidatures ont été modifiées'
      rescue ActiveRecord::RecordInvalid, ArgumentError => e
        redirect_to dashboard_candidatures_path, alert: "Erreur lors de la modification des candidatures: #{e.message}"
      rescue StandardError => e
        redirect_to dashboard_candidatures_path, alert: "Erreur lors de la modification des candidatures: #{e.message}"
      end
    end

    private

    def valid_transition?(transition)
      allowed_transitions = %w[approve reject cancel]
      allowed_transitions.include?(transition)
    end
  end
end
