require 'net/http'
require 'uri'
require 'json'

module Services
  class CegidCrawler
    include Rails.application.routes.url_helpers

    def initialize
      @data = fetch_data
    end

    def fetch_data
      uri = URI(ENV['CEGID_DECATHLON_URL'])
      response = Net::HTTP.get_response(uri)
      return unless response.is_a?(Net::HTTPSuccess)

      JSON.parse(response.body)
    end

    def fetch_and_create_offers_decathlon
      @data['ads'].each do |offer_data|
        process_offer(offer_data)
      end

      remove_old_offers('Decathlon')
    end

    def process_offer(offer_data)
      @token = get_token_from_operator('Decathlon')
      remote_id = offer_data['reference']

      return if InternshipOffer.exists?(remote_id: remote_id)

      title = offer_data['title']
      description = sanitize_html(offer_data['description'])[0..500]
      employer_name = offer_data.dig('brand', 'name')
      employer_description = sanitize_html(offer_data['profile'])[0..500]
      employer_website = 'https://www.decathlon.fr/'
      siret = '50056940503239'
      coordinates = coordinates_from_position
      street = offer_data.dig('address', 'parts', 'street')
      city = offer_data.dig('address', 'parts', 'city')
      zipcode = offer_data.dig('address', 'parts', 'zip')
      sector_uuid = Sector.find_by(name: 'Commerce et distribution').uuid
      remote_id = offer_data['reference']
      max_candidates = 1
      is_public = false
      grades = %w[seconde troisieme]
      weeks = InternshipOffers::Api.mandatory_seconde_weeks
      daily_hours = { "lundi": ['9:00', '17:00'], "mardi": ['9:00', '17:00'], "mercredi": ['9:00', '17:00'],
                      "jeudi": ['9:00', '17:00'], "vendredi": ['9:00', '17:00'] }
      permalink = offer_data['apply_url']
      lunch_break = 'Repas sur place'

      uri = URI("#{ENV['HOST']}/api/v2/internship_offers")
      http = Net::HTTP.new(uri.host, uri.port)
      http.use_ssl = uri.scheme == 'https'

      request = Net::HTTP::Post.new(uri.path)
      request['Authorization'] = "Bearer #{@token}"
      request['Content-Type'] = 'application/json'

      payload = {
        internship_offer: {
          title: title,
          description: description,
          employer_name: employer_name,
          employer_description: employer_description,
          employer_website: employer_website,
          siret: siret,
          coordinates: coordinates,
          street: street,
          zipcode: zipcode,
          city: city,
          sector_uuid: sector_uuid,
          remote_id: remote_id,
          max_candidates: max_candidates,
          is_public: is_public,
          daily_hours: daily_hours,
          permalink: permalink,
          lunch_break: lunch_break,
          grades: grades,
          weeks: weeks
        }
      }

      request.body = payload.to_json
      response = http.request(request)

      if response.is_a?(Net::HTTPSuccess)
        Rails.logger.info "Successfully created internship offer: #{remote_id}"
      else
        Rails.logger.error "Failed to create internship offer: #{response.body}"
      end
    end

    private

    def sanitize_html(html)
      return nil if html.nil?

      ActionController::Base.helpers.sanitize(html, tags: %w[p b i u li ul ol br])
    end

    # not used
    # def parse_datetime(datetime_str)
    #   DateTime.parse(datetime_str)
    # rescue StandardError
    #   nil
    # end

    def coordinates_from_position
      lat = @data.dig('address', 'position', 'lat')
      lon = @data.dig('address', 'position', 'lon')

      # if no lat and lon use Geocoder
      if lat.nil? || lon.nil?
        address_parts = []
        street = @data.dig('address', 'parts', 'street')
        zipcode = @data.dig('address', 'parts', 'zip')
        city = @data.dig('address', 'parts', 'city')

        address_parts << street if street.present?
        address_parts << zipcode if zipcode.present?
        address_parts << city if city.present?

        return nil if address_parts.empty?

        address = address_parts.join(', ')
        coordinates = Geocoder.search(address).first&.coordinates
        return nil unless coordinates

        lat = coordinates[0]
        lon = coordinates[1]
      end

      return nil unless lat && lon

      RGeo::Geographic.spherical_factory(srid: 4326).point(lon.to_f, lat.to_f)
    end

    # not used
    # def format_employer_name
    #   [@data.dig('entity', 'public_name'), @data.dig('brand', 'name')].compact.first
    # end

    def get_token_from_operator(operator_name)
      operator = Operator.find_by(name: operator_name)
      user = operator.operators.first
      JwtAuth.encode(user_id: user.id)
    end

    def remove_old_offers(operator_name)
      remote_ids = @data['ads'].map { |ad| ad['reference'] }

      operator = Operator.find_by(name: operator_name)
      offers = InternshipOffer.where(employer_id: operator.id)

      offers.each do |offer|
        unless remote_ids.include?(offer.remote_id)
          offer.destroy
          puts "Offer #{offer.remote_id} removed"
        end
      end

      puts "Total offers removed: #{offers.count}"
    end
  end
end
