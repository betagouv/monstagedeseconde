class CompaniesController < ApplicationController
  layout 'search'

  def index
    @city_coordinates = Geofinder.coordinates(search_params[:city])
    return [] if @city_coordinates.empty?

    @latitude        = search_params[:latitude].presence
    @longitude       = search_params[:longitude].presence
    @radius_in_km    = search_params[:radius_in_km].presence || 10
    appellation_code = search_params[:appellationCode].presence

    @companies = []
    coded_craft = CodedCraft.fetch_coded_craft(appellation_code)
    @level_name = ''

    iteration = 0
    while iteration <= 3 && @companies.to_a.count.zero? do
      @level_name, sibling_coded_crafts = coded_craft.siblings(level: iteration)
      service = Services::ImmersionFacile.new(latitude: latitude,
                                              longitude: longitude,
                                              radius_in_km: radius_in_km,
                                              appellation_codes: sibling_coded_crafts.pluck(:ogr_code))
      @companies = service.perform
      iteration += 1
    end
    render :index
  end

  private

  attr_accessor :latitude, :longitude, :appellation_codes
  attr_reader :city, :keyword, :radius_in_km

  def search_params
    params.permit(:city,
                  :latitude,
                  :longitude,
                  :radius_in_km,
                  :appellationCode,
                  :keyword)
  end
end