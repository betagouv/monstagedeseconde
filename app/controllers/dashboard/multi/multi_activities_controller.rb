# frozen_string_literal: true

module Dashboard::Multi
  # Step 1 of multi-activity internship offer creation
  class MultiActivitiesController < ApplicationController
    before_action :authenticate_user!
    before_action :sanitize_content, only: %i[create update]
    before_action :fetch_multi_activity, only: %i[edit update]

    # render step 1
    def new
      if params[:id].present?
        @multi_activity = MultiActivity.find(params[:id])
        authorize! :edit, @multi_activity
      else
        authorize! :create, MultiActivity
        @multi_activity = MultiActivity.new
      end
    end

    # process step 1
    def create
      authorize! :create, MultiActivity

      @multi_activity ||= MultiActivity.new(multi_activity_params)
      @multi_activity.employer_id = current_user.id

      if @multi_activity.save
        redirect_to new_dashboard_multi_multi_coordinator_path(multi_activity_id: @multi_activity.id,
                                                         submit_button: true),
                    notice: 'Les informations ont bien été enregistrées'
      else
        log_error(object: @multi_activity)
        render :new, status: :bad_request
      end
    end

    # render back to step 1
    def edit
      authorize! :edit, @multi_activity
    end

    # process update following a back to step 1
    def update
      authorize! :update, @multi_activity

      if @multi_activity.update(multi_activity_params)
        redirect_to new_dashboard_multi_multi_activity_path(id: @multi_activity.id)
      else
        log_error(object: @multi_activity)
        render :new, status: :bad_request
      end
    end

    private

    def fetch_multi_activity
      @multi_activity = MultiActivity.find(params[:id])
    end

    def multi_activity_params
      params.require(:multi_activity)
            .permit(:title, :description)
    end

    def sanitize_content
      return unless multi_activity_params[:description].present?

      multi_activity_params[:description] =
        strip_content(multi_activity_params[:description])
    end
  end
end

