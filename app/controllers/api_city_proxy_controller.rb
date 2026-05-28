# ad blockers can block API, so we proxy our calls to it.
# not the neciest solution, but safest
class ApiCityProxyController < ApplicationController
  def search
    returned_value = Rails.cache.fetch(cache_key) { api_request }
    render json: returned_value[:json], status: returned_value[:code]
  end

  private

  def cache_key
    "autocomplete_city/#{permitted_params.to_unsafe_h.to_param}"
  end

  def api_request
    response = Api::AutocompleteCity.search(permitted_params)
    {
      json: response.body,
      status: response.code
    }
  end

  def permitted_params
    params.permit(:nom,
                  :fields,
                  :limit,
                  :boost,
                  :code,
                  :population,
                  :codePostal)
  end
end