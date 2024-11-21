module InternshipOffers
  class InternshipApplicationsController < ApplicationController
    before_action :authenticate_user!
    before_action :fetch_offer, only: %i[new]

    def new
      @application_weeks = nil
    end

    private

    def fetch_offer
      @internship_offer = InternshipOffer.find(params[:internship_offer_id])
    end
  end
end
