class ProgressChannel < ApplicationCable::Channel
  def subscribed
    stream_from "progress_#{params[:job_id]}"
  end

  def unsubscribed
    # cleanup if needed
  end
end
