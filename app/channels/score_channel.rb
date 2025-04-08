class ScoreChannel < ApplicationCable::Channel
  Score = Struct.new(:title, :description, :sector, :uid, :id)

  def subscribed
    stream_from params['uid']
  end

  def score(params)
    title = params['title']
    description = params['description']
    sector = params['sector'] || ''
    uid = params['uid']
    id = params['id'] || 0

    instance = Score.new(title, description, sector, uid, id)
    score = Services::DescriptionScoring.new(instance:).perform
    ActionCable.server.broadcast(uid, { score: score })
  end

  rescue_from 'StandardError', with: :deliver_error_message

  private

  def deliver_error_message(e)
    puts "An error occurred: #{e.message}"
    Rails.logger.error("An error occurred: #{e.message}")
    ActionCable.server.broadcast(uid, { error: e.message })
  end
end
