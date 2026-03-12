# frozen_string_literal: true

class Current < ActiveSupport::CurrentAttributes
  attribute :user, :request_url, :request_params, :request_id
end
