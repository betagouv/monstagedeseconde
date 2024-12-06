module Services
  class ImmersionFacile < ApiRequestsHelper
    IMMERSION_FACILE_ENDPOINT_URL = ENV['IMMERSION_FACILE_API_URL'] + '/search'

    # sample of json response : {
    # [
    #   {
    #     "additionalInformation": "Some additional information",
    #     "address": {
    #       "departmentCode": "75",
    #       "postcode": "75001",
    #       "streetNumberAndAddress": "1 rue de Rivoli",
    #       "city": "Paris"
    #     },
    #     "rome": "B1805",
    #     "romeLabel": "Stylisme",
    #     "appellations": [
    #       {
    #         "appellationCode": "19540",
    #         "appellationLabel": "Styliste",
    #         "score": 0
    #       },
    #       {
    #         "appellationCode": "12831",
    #         "appellationLabel": "Concepteur / Conceptrice maquettiste en accessoires de mode",
    #         "score": 0
    #       }
    #     ],
    #     "contactMode": "EMAIL",
    #     "customizedName": "Ma super boite",
    #     "distance_m": 1225,
    #     "fitForDisabledWorkers": false,
    #     "naf": "123",
    #     "nafLabel": "Fabrication de vêtements",
    #     "name": "Raison sociale de ma super boite",
    #     "numberOfEmployeeRange": "",
    #     "position": {
    #       "lat": 48.8589507,
    #       "lon": 2.3468078
    #     },
    #     "siret": "11110000222200",
    #     "voluntaryToImmersion": true,
    #     "website": "www.masuperboite.com",
    #     "locationId": "123"
    #   }
    # ]

    def perform
      response = get_request
      if response.nil? || !response.respond_to?(:body)
        error_message = 'Faulty request : consider contacting developper'
        Rails.logger.error(error_message)
      end
      if response && response.respond_to?(:code) && status?(200, response)
        JSON.parse(response.body)
      else
        log_failure(response)
        []
      end
    end

    private

    def log_failure(response)
      error_message = "Error #{response.try(:code)} with message: " \
                      "#{response} for immmersion-" \
                      "facilitée with #{city} search"
      Rails.logger.error(error_message)
    end

    def get_request_uri
      URI("#{IMMERSION_FACILE_ENDPOINT_URL}?#{query_string}")
    end

    def query_string
      body = {
        distanceKm: radius_in_km.to_i,
        latitude: latitude.to_f,
        longitude: longitude.to_f,
        sortedBy: 'distance'
      }
      query_str = body.to_query
      unless appellation_codes.empty?
        appellation_codes.each do |appellation_code|
          query_str = "#{query_str}&appellationCodes[]=#{appellation_code}"
        end
      end
      query_str
    end

    def default_headers
      {
        'Accept': 'application/json',
        'Authorization': ENV['IMMERSION_FACILE_API_KEY']
      }
    end

    attr_reader :city, :appellation_codes, :longitude, :latitude
    attr_accessor :radius_in_km

    private

    def initialize(latitude:, longitude:, radius_in_km: 10, appellation_codes: [])
      @longitude = longitude
      @latitude = latitude
      @radius_in_km = radius_in_km
      @appellation_codes = check_appellation_codes(appellation_codes)
    end

    def check_appellation_codes(appellation_codes)
      return [] if appellation_codes.empty?
      return [] unless appellation_codes.respond_to?(:map)

      appellation_codes = appellation_codes.map(&:to_s)
      appellation_codes.all? { |code| code.match?(/\A\d{4,}\z/) } ? appellation_codes : []
    end
  end
end
