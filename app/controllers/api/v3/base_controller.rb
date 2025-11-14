# frozen_string_literal: true

module Api
  module V3
    class BaseController < Api::ApiBaseController
      include Api::JsonApiRenderable

      skip_before_action :verify_authenticity_token
    end
  end
end

