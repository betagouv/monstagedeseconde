# ad blockers can block API, so we proxy our calls to it.
# not the neciest solution, but safest
class ApiCityProxyController < ApplicationController
  def search
    time_start = Time.now
    cache = Rails.cache
    cache_key = { autocomplete_city: permitted_params }
    cache.fetch(cache_key) do
      api_request
    end
    returned_value = cache.fetch(cache_key)
    time_end = Time.now
    puts '================================'
    puts "Elapsed time for city caching #{permitted_params[:nom]} - #{permitted_params[:code]}: #{(time_end - time_start) * 1000} ms"
    puts '================================'
    puts ''
    render json: returned_value[:json], status: returned_value[:code]
  end

  private

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