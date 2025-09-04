# frozen_string_literal: true

class ResetReviewDataController < ApplicationController
  content_security_policy false
  def new
    @job_id = SecureRandom.uuid
  end

  def create
    job_id = params[:job_id]
    redirect_to root_path unless ENV.fetch('ENABLE_REVIEW_DATA_RESET', 'false') == 'true' || Rails.env.production?

    RebuildReviewJob.perform_later(job_id)
    head :no_content
  end
end
