module Services
  class SendContactImmersionFacilite
    IMMERSION_FACILE_ENDPOINT_URL = "https://staging.immersion-facile.beta.gouv.fr/api/v2/contact-establishment".freeze
    
    # Staging
    # IMMERSION_FACILE_ENDPOINT_URL = "https://staging.immersion-facile.beta.gouv.fr/api/v2/contact-establishment".freeze


    def perform
      response = post_request
      if response.nil? || !response.respond_to?(:body)
        error_message = "Faulty request : consider contacting developper"
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
      puts response
      puts response.try(:code)
      puts response.try(:body)

      error_message = "Error #{response.try(:code)} with message: " \
                      "#{response} for immmersion-facilitée"
      Rails.logger.error(error_message)
    end

    def post_request
      # post request to immersion facile with body
      uri = get_request_uri
      http = Net::HTTP.new(uri.host, uri.port)
      http.use_ssl = true
      request = Net::HTTP::Post.new(uri, default_headers)
      request.body = body_request
      http.request(request)
    end


    def get_request_uri
      URI(IMMERSION_FACILE_ENDPOINT_URL)
    end

    def body_request
      a = {
        potentialBeneficiaryFirstName: first_name,
        potentialBeneficiaryLastName: last_name,
        potentialBeneficiaryEmail: email,
        appellationCode: appellation_code,
        siret: siret,
        contactMode: 'EMAIL',
        message: message,
        potentialBeneficiaryPhone: phone,
        immersionObjective: message,
        locationId: location_id
      }.to_json
      puts a

      {
        potentialBeneficiaryFirstName: first_name,
        potentialBeneficiaryLastName: last_name,
        potentialBeneficiaryEmail: email,
        appellationCode: appellation_code,
        siret: siret,
        contactMode: 'EMAIL',
        message: message,
        potentialBeneficiaryPhone: phone,
        immersionObjective: message,
        locationId: location_id
      }.to_json
    end

    # expected: Int|Array[Int],
    # response: HttpResponse,
    def status?(expected, response)
      Array(expected).include?(response.code.to_i)
    end

    def default_headers
      {
        'Accept': 'application/json' ,
        'Authorization': ENV['IMMERSION_FACILE_API_KEY']
      }
    end

    attr_reader :first_name, :last_name, :email, :phone, :appellation_code, :siret, :message, :location_id

    private

    def initialize(params)
      @first_name = params[:first_name]
      @last_name = params[:last_name]
      @email = params[:email]
      @phone = params[:phone]
      @appellation_code = params[:appellation_code]
      @siret = params[:siret]
      @message = "Découvrir un métier ou un secteur d'activité" #params[:message]
      @location_id = params[:location_id]
    end

    def check_appellation_codes(appellation_codes)
      return [] if appellation_codes.empty?
      return [] unless appellation_codes.respond_to?(:map)

      appellation_codes = appellation_codes.map(&:to_s)
      (appellation_codes.all? { |code| code.match?(/\A\d{4,}\z/)}) ? appellation_codes: []
    end
  end
end