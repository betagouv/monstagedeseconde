class UpdateHubspotContactJob < ApplicationJob
  queue_as :default

  def perform(user_id)
    Services::UpdateHubspotContact.new(user_id: user_id).perform
  end
end