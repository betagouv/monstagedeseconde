# frozen_string_literal: true

# ad blockers can block API, so we proxy our calls to it.
# not the neciest solution, but safest
class ApiImmersionFacileProxyController < ApplicationController
  def search
    render json: Api::AutocompleteImmersionFacile.search(
      params: params.permit(:city, :radius, :keyword)
    )
  end
end

