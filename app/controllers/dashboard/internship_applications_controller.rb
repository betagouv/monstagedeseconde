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
      authorize! :update, InternshipApplication
      @internship_applications = InternshipApplication.where(id: params[:ids].split(','))

      begin
        ActiveRecord::Base.transaction do
          @internship_applications.each do |internship_application|
            internship_application.send(params[:transition])
            internship_application.update!(rejected_message: params[:rejection_message])
          end
        end
        redirect_to dashboard_candidatures_path, notice: 'Les candidatures ont été modifiées'
      rescue ActiveRecord::RecordInvalid => e
        redirect_to dashboard_candidatures_path, alert: "Erreur lors de la modification des candidatures: #{e.message}"
      rescue NoMethodError => e
        redirect_to dashboard_candidatures_path, alert: "Transition invalide: #{e.message}"
      rescue StandardError => e
        redirect_to dashboard_candidatures_path, alert: "Erreur lors de la modification des candidatures: #{e.message}"
      end
    end
  end
end
