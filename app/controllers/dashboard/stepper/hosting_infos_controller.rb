# frozen_string_literal: true

module Dashboard::Stepper
  # Step 3 of internship offer creation: fill in hosting info
  class HostingInfosController < ApplicationController
    before_action :authenticate_user!

    # render step 3
    def new
      authorize! :create, HostingInfo

      @hosting_info = HostingInfo.new
      @organisation = Organisation.find(params[:organisation_id])
      @internship_offer_info = InternshipOfferInfo.find(params[:internship_offer_info_id])
    end

    # process step 3
    def create
      authorize! :create, HostingInfo
      @hosting_info = HostingInfo.new(
        {}.merge(hosting_info_params)
        .merge(employer_id: current_user.id)
      )
      if @hosting_info.save!
        redirect_to(new_dashboard_stepper_practical_info_path(
                      organisation_id: params[:organisation_id],
                      internship_offer_info_id: params[:internship_offer_info_id],
                      hosting_info_id: @hosting_info.id
        ))
      else
        @organisation = Organisation.find(params[:organisation_id])
        render :new, status: :bad_request
      end

    rescue ActiveRecord::RecordInvalid
      @organisation = Organisation.find(params[:organisation_id])
      render :new, status: :bad_request
    end

    # render back to step 3
    def edit
      @hosting_info = HostingInfo.find(params[:id])
      @organisation = Organisation.find(params[:organisation_id])
      authorize! :edit, @hosting_info
    end

    # process update following a back to step 3 (info was created, it's updated)
    def update
      @hosting_info = HostingInfo.find(params[:id])
      authorize! :update, @hosting_info

      if @hosting_info.update(hosting_info_params)
        if params[:practical_info_id].present? && PracticalInfo.find(params[:practical_info_id])
        redirect_to edit_dashboard_stepper_practical_info_path(
          organisation_id: params[:organisation_id],
          internship_offer_info_id: params[:internship_offer_info_id],
          hosting_info_id: @hosting_info.id,
          id: params[:practical_info_id]
        )
        else
          redirect_to new_dashboard_stepper_practical_info_path(
            organisation_id: params[:organisation_id],
            internship_offer_info_id: params[:internship_offer_info_id],
            hosting_info_id: @hosting_info.id,
          )
        end
      else
        @organisation = Organisation.find(params[:organisation_id])
        render :new, status: :bad_request
      end
    end

    private

    def hosting_info_params
      params.require(:hosting_info)
            .permit(
              :employer_id,
              :max_candidates,
              :period,
              :school_id
              )
    end
  end
end
