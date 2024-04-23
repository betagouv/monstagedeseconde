class CompaniesController < ApplicationController
  layout 'search'

  def index
    @city_coordinates = Geofinder.coordinates(search_params[:city])
    return [] if @city_coordinates.empty?

    @latitude = @city_coordinates.first
    @longitude = @city_coordinates.last
    @radius_in_km = search_params[:radius_in_km].presence || 10

    service = Services::ImmersionFacile.new({ latitude: latitude,
                                              longitude: longitude,
                                              radius_in_km: radius_in_km })
    @companies = service.perform
    @pages = InternshipOffer.all
                            .order(created_at: :desc)
                            .page(params[:page])
                            .per(3)
    render :index
  end

  private

  def prefered_keys = []

  attr_accessor :latitude, :longitude, :radius_in_km
  attr_reader :city, :keyword

  def search_params
    params.permit(:city,
                  :latitude,
                  :longitude,
                  :radius_in_km,
                  :keyword)
  end
end