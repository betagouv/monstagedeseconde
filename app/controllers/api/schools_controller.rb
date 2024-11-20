# frozen_string_literal: true

module Api
  # Search school by city
  class SchoolsController < ApiBaseController
    SEARCH_LIMIT = 150

    def search
      render_success(
        object: result,
        status: 200,
        json_options: {
          methods: %i[pg_search_highlight_city pg_search_highlight_name]
        }
      )
    end

    def nearby
      render_success(
        object: School.nearby(latitude: params[:latitude], longitude: params[:longitude], radius: 60_000),
        status: 200,
        json_options: {}
      )
    end

    private

    def result
      search_key = params[:query]
      cache_key = "autocomplete_school_#{search_key}"
      Rails.cache.fetch(cache_key) do
        Api::AutocompleteSchool.new(term: search_key, limit: SEARCH_LIMIT).to_json
      end
      cached_response = Rails.cache.fetch(cache_key) || { match_by_city: {}, match_by_name: [], no_match: true }
      JSON.parse(cached_response)
    end
  end
end
