# frozen_string_literal: true

class BoardingHousesController < ApplicationController
  # Returns every boarding house matching the current offer search location
  # (no pagination): within the given radius if lat/long are provided,
  # otherwise every boarding house with valid coordinates.
  def search
    latitude = params[:latitude].to_f
    longitude = params[:longitude].to_f
    radius = (params[:radius].presence || Nearbyable::DEFAULT_NEARBY_RADIUS_IN_METER).to_i

    scope = BoardingHouse.where('available_places > 0').where.not(coordinates: nil)
    if latitude.nonzero? && longitude.nonzero?
      scope = scope.nearby(latitude: latitude, longitude: longitude, radius: radius)
    end

    render json: {
      boardingHouses: scope.map { |bh| format_boarding_house(bh) }
    }
  end

  private

  def format_boarding_house(bh)
    {
      id: bh.id,
      name: bh.name,
      lat: bh.coordinates.latitude,
      lon: bh.coordinates.longitude,
      available_places: bh.available_places,
      contact_phone: bh.contact_phone,
      contact_email: bh.contact_email,
      street: bh.street,
      zipcode: bh.zipcode,
      city: bh.city
    }
  end
end
