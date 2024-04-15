module Services
  class InsertionFacile
    INSERTION_FACILE_ENDPOINT_URL = "https://staging.immersion-facile.beta.gouv.fr/api/v2/search".freeze
    # sample of json response : {
    #   {"rome"=>"K1304",
    #    "siret"=>"49431141800037",
    #    "distance_m"=>189.08988282,
    #    "name"=>"O2 TOURS SUD",
    #    "website"=>"",
    #    "additionalInformation"=>"",
    #    "fitForDisabledWorkers"=>false,
    #    "romeLabel"=>"Services domestiques",
    #    "appellations"=>[{"appellationCode"=>"10857", "appellationLabel"=>"Aide ménager / ménagère à domicile", "score"=>10}],
    #    "naf"=>"8810A",
    #    "nafLabel"=>"Action sociale sans hébergement pour personnes âgées et pour personnes handicapées",
    #    "address"=>{"streetNumberAndAddress"=>"Boulevard Béranger", "postcode"=>"37000", "city"=>"Tours", "departmentCode"=>"37"},
    #    "position"=>{"lon"=>0.6864227, "lat"=>47.3900179},
    #    "locationId"=>"e8766948-cdee-4f80-a4a9-c70727a8a105",
    #    "contactMode"=>"IN_PERSON",
    #    "numberOfEmployeeRange"=>"50-99",
    #    "voluntaryToImmersion"=>true}
    # }

    def perform
      response = get_request
      if response.nil? || !response.respond_to?(:body)
        error_message = "Faulty request : consider contacting developper"
        Rails.logger.error(error_message)
        return nil
      end
      if status?(200, response)
        Rails.logger.debug("Got a response for #{city}")
        JSON.parse(response.body)
      else
        log_failure(response)
      end
    end

    attr_reader :phone_number, :content , :sender_name, :user, :pass, :campaign_name

    private

    def log_failure(response)
      error_message = "Error #{response.code} with message: " \
                      "#{JSON.parse(response.body)} for immmersion-" \
                      "facilitée with #{city} search"
      Rails.logger.error(error_message)
    end

    def get_request
      uri = get_request_uri
      http = Net::HTTP.new(uri.host, uri.port)
      http.use_ssl = true
      request = Net::HTTP::Get.new(uri, default_headers)
      http.request(request)
    end

    def get_request_uri
      URI("#{INSERTION_FACILE_ENDPOINT_URL}?#{making_body.to_query}")
    end

    def making_body
      fetch_location
      {
        longitude: longitude,
        latitude: latitude,
        distanceKm: radius / 1000.0,
        sortedBy: 'distance',
        appellationCodes: appellation_codes
      }
    end

    # expected: Int|Array[Int],
    # response: HttpResponse,
    def status?(expected, response)
      Array(expected).include?(response.code.to_i)
    end

    def default_headers
      {
        'Accept': 'application/json' ,
        'Authorization': ENV['INSERTION_FACILE_API_KEY']
      }
    end


    attr_reader :city, :radius, :appellation_codes
    attr_accessor :longitude, :latitude

    private

    def initialize(city:, radius: 10_000, appellation_codes: [])
      @city = city
      @longitude = nil
      @latitude = nil
      @radius = radius
      @appellation_codes = check_appellation_codes(appellation_codes)
    end

    def fetch_location
      @latitude, @longitude = Geofinder.coordinates(city)
    end

    def check_appellation_codes(appellation_codes)
      appellation_codes = appellation_codes.map(&:to_s)
      appellation_codes.all? { |code| code.match?(/\A\d{4,}\z/)} ? appellation_codes: []
    end
  end
end