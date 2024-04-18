# frozen_string_literal: true

# ad blockers can block API, so we proxy our calls to it.
# not the neciest solution, but safest
class ApiInsertionFacileProxyController < ApplicationController
  def search
    render json: Api::AutocompleteInsertionFacile.search(
      params: params.permit(:city, :radius, :keyword)
    )
  end
end

