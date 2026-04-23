# frozen_string_literal: true

class BoardingHouse < ApplicationRecord
  include Nearbyable

  attr_writer :latitude, :longitude

  belongs_to :academy

  before_validation :set_department_from_zipcode
  before_validation :apply_manual_coordinates
  before_validation :geocode_from_address

  validates :name, presence: true
  validates :zipcode, presence: true
  validates :city, presence: true
  validates :department, presence: true
  validates :available_places, numericality: { greater_than_or_equal_to: 0 }, allow_nil: true
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

  def latitude
    return @latitude if defined?(@latitude)

    coordinates&.lat
  end

  def longitude
    return @longitude if defined?(@longitude)

    coordinates&.lon
  end

  private

  def manual_coordinates_provided?
    defined?(@latitude) && defined?(@longitude) && @latitude.present? && @longitude.present?
  end

  def apply_manual_coordinates
    return unless manual_coordinates_provided?

    self.coordinates = { latitude: @latitude.to_f, longitude: @longitude.to_f }
  end

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
    return if manual_coordinates_provided?
    return if coordinates_present? && (new_record? || !address_changed?)
    return if full_address.blank?

    coords = lookup_coordinates
    self.coordinates = { latitude: coords[0], longitude: coords[1] } if coords
  end

  # BAN's scoring ignores zipcode/city when they appear as free text,
  # so a street name that happens to exist in another commune can hijack
  # the result. We rely on the `postcode` filter to constrain BAN, and
  # cascade down to commune-level lookups when the precise address can't
  # be resolved (bad/CEDEX zipcode, CEDEX city suffix, etc.). As a last
  # resort we drop the postcode filter but verify the returned commune,
  # which catches cases where the saved zipcode doesn't match the actual
  # postcode of the street (e.g. 97400 vs 97490 in Saint-Denis).
  def lookup_coordinates
    clean_city = expand_saint_abbreviation(city_without_cedex)
    zip = zipcode.to_s.strip
    street_str = expand_saint_abbreviation(street.to_s.strip)
    variants = postcode_variants(zip)

    if street_str.present?
      street_query = [street_str, clean_city].reject(&:blank?).join(' ')
      variants.each do |pc|
        coords = Geocoder.coordinates(street_query, lookup: :ban_data_gouv_fr, params: { postcode: pc })
        return coords if coords
      end
    end

    commune_query = clean_city.presence || zip.presence
    if commune_query.present?
      variants.each do |pc|
        coords = Geocoder.coordinates(commune_query, lookup: :ban_data_gouv_fr, params: { postcode: pc })
        return coords if coords
      end
    end

    lookup_without_postcode(street_str, clean_city)
  rescue StandardError => e
    Rails.logger.warn("[BoardingHouse#geocode] failed for #{full_address.inspect}: #{e.message}")
    nil
  end

  def lookup_without_postcode(street_str, clean_city)
    return nil if clean_city.blank?

    query = [street_str, clean_city].reject(&:blank?).join(' ')
    # The BAN result wraps the whole FeatureCollection — we walk
    # `features` ourselves to inspect candidates beyond the top match.
    results = Geocoder.search(query, lookup: :ban_data_gouv_fr, params: { limit: 10 })
    return nil if results.empty?

    Array(results.first.features).each do |feature|
      props = feature['properties'] || {}
      next unless commune_matches?(props['city'], clean_city)

      lon, lat = feature.dig('geometry', 'coordinates')
      return [lat, lon] if lat && lon
    end
    nil
  end

  def commune_matches?(banned_city, expected_city)
    return false if banned_city.blank? || expected_city.blank?

    normalize_commune(banned_city) == normalize_commune(expected_city)
  end

  def normalize_commune(value)
    I18n.transliterate(value.to_s).downcase.gsub(/[^a-z0-9]+/, ' ').strip
  end

  def city_without_cedex
    city.to_s.sub(/\s+CEDEX(\s*\d*)?\s*\z/i, '').strip
  end

  def expand_saint_abbreviation(value)
    return value if value.blank?

    value.gsub(/\bSTE\b/i, 'Sainte').gsub(/\bST\b/i, 'Saint')
  end

  def postcode_variants(zip)
    return [] if zip.blank?

    variants = [zip]
    base = zip.sub(/\d{2}\z/, '00')
    variants << base if base.match?(/\A\d{5}\z/) && base != zip
    variants
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
