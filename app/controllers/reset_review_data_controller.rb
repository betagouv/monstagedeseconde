# frozen_string_literal: true

class ResetReviewDataController < ApplicationController
  content_security_policy false
  def new
    @job_id = SecureRandom.uuid
  end

  def create
    redirect_to root_path unless current_ability.can?(:show, :account, :rebuild_review_job)
    redirect_to root_path if Rails.env.production?
    redirect_to root_path if Rails.env.staging?
    redirect_to root_path unless ENV.fetch("ENABLE_REVIEW_DATA_RESET", "false") == "true"

    job_id = params[:job_id]
    RebuildReviewJob.perform_later(job_id)
    head :no_content
  end
end
