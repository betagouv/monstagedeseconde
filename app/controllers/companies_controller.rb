class CompaniesController < ApplicationController
  layout 'search'
  DEFAULT_RADIUS_IN_KM = 10

  def index
    @city_coordinates = Geofinder.coordinates(search_params[:city])
    return [] if @city_coordinates.empty?

    @companies    = []
    @level_name   = 'Pilote de ligne'
    @latitude     = search_params[:latitude].presence
    @longitude    = search_params[:longitude].presence
    @radius_in_km = search_params[:radius_in_km].presence || DEFAULT_RADIUS_IN_KM
    parameters = {
      latitude: @latitude,
      longitude: @longitude,
      radius_in_km: @radius_in_km
    }

    appellation_code = search_params[:appellationCode].presence
    if appellation_code.present?
      @level_name, @companies = fetch_companies_by_appellation_code(appellation_code, parameters)
    else
      @companies = fetch_companies(parameters)
    end
    render :index
  end

  def search
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

  def fetch_companies(parameters)
    Services::ImmersionFacile.new(**parameters).perform
  end

  def fetch_companies_by_appellation_code(appellation_code, parameters)
    coded_craft = CodedCraft.fetch_coded_craft(appellation_code)
    @level_name = ''
    iteration = 0
    while iteration <= 3 && @companies.to_a.count.zero? do
      @level_name, sibling_coded_crafts = coded_craft.siblings(level: iteration)
      parameters.merge!(appellation_codes: sibling_coded_crafts.pluck(:ogr_code))
      @companies = fetch_companies(parameters)
      iteration += 1
    end
    [@level_name, @companies]
  end
end