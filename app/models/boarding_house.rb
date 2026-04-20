# frozen_string_literal: true

class BoardingHouse < ApplicationRecord
  include Nearbyable

  belongs_to :academy

  before_validation :set_department_from_zipcode
  before_validation :geocode_from_address

  validates :name, presence: true
  validates :zipcode, presence: true
  validates :city, presence: true
  validates :department, presence: true
  validates :available_places, numericality: { greater_than_or_equal_to: 0 }, allow_nil: true
  validates :contact_email, format: { with: Devise.email_regexp }, allow_blank: true
  validate :department_belongs_to_academy
  validate :coordinates_must_be_present

  # Nearbyable's default coordinates validator is replaced by
  # `coordinates_must_be_present` below, which produces a clearer error message.
  def coordinates_are_valid?
    true
  end

  def full_address
    [street, zipcode, city].map { |part| part.to_s.strip.presence }.compact.join(' ')
  end

  private

  def set_department_from_zipcode
    return if zipcode.blank?

    dept = Department.fetch_by_zipcode(zipcode: zipcode)
    self.department = dept.name if dept
  end

  def department_belongs_to_academy
    return if zipcode.blank? || academy.blank?

    dept = Department.fetch_by_zipcode(zipcode: zipcode)
    return if dept.nil?

    unless academy.departments.include?(dept)
      errors.add(:zipcode, :not_in_academy, message: "ne correspond pas à un département de l'académie de #{academy.name}")
    end
  end

  def geocode_from_address
    return if coordinates_present? && (new_record? || !address_changed?)
    return if full_address.blank?

    coords = lookup_coordinates(full_address)
    self.coordinates = { latitude: coords[0], longitude: coords[1] } if coords
  end

  def lookup_coordinates(address)
    Geocoder.coordinates(address, lookup: :ban_data_gouv_fr) ||
      Geocoder.coordinates(address)
  rescue StandardError => e
    Rails.logger.warn("[BoardingHouse#geocode] failed for #{address.inspect}: #{e.message}")
    nil
  end

  def coordinates_present?
    coordinates.present? &&
      coordinates.latitude.to_f.nonzero? &&
      coordinates.longitude.to_f.nonzero?
  end

  def address_changed?
    street_changed? || zipcode_changed? || city_changed?
  end

  def coordinates_must_be_present
    return if coordinates_present?

    errors.add(:base,
               "Impossible de géolocaliser l'adresse « #{full_address} ». " \
               "Vérifiez que l'adresse est correcte.")
  end
end
