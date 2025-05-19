# frozen_string_literal: true

# ad blockers can block API, so we proxy our calls to it.
# not the neciest solution, but safest
class ApiSireneProxyController < ApplicationController
  include Api::Throttle
  MAX_REQUESTS_PER_MINUTE = 50 * 60 # 50 requests per second
  before_action :throttle_api_requests_for_siret

  def search
    response = Api::AutocompleteSirene.search_by_siret(siret: params[:siret])
    render json: response.body, status: response.code
  end

  def throttle_api_requests_for_siret
    site_throttle_api_requests 'siret', MAX_REQUESTS_PER_MINUTE
  end
end

