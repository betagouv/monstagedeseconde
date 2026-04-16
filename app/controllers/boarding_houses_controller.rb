# frozen_string_literal: true

class BoardingHousesController < ApplicationController
  def search
    latitude = params[:latitude].to_f
    longitude = params[:longitude].to_f
    radius = (params[:radius].presence || 60_000).to_i

    boarding_houses = if latitude.nonzero? && longitude.nonzero?
                        BoardingHouse.nearby(latitude: latitude, longitude: longitude, radius: radius)
                                     .where('available_places > 0')
                      else
                        BoardingHouse.where('available_places > 0')
                                     .where.not(coordinates: nil)
                      end

    render json: {
      boardingHouses: boarding_houses.map { |bh| format_boarding_house(bh) }
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
